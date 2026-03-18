# frozen_string_literal: true

require 'csv'
require 'time'

DATASET_NAME = ENV['DATASET_NAME']
TABLE_NAME = ENV['TABLE_NAME']

MF_FILE_PATH = './files/mf.csv'.freeze
BQ_SQL_FILE_PATH = './files/bq.sql'.freeze
REQUIRED_HEADERS = %w[日付 内容 金額（円） 保有金融機関 大項目 中項目 メモ 振替 ID].freeze
TEXT_FIELDS = %w[内容 保有金融機関 大項目 中項目 メモ ID].freeze

def validate_headers(headers)
  missing_headers = REQUIRED_HEADERS - headers
  return if missing_headers.empty?

  raise ArgumentError, "CSVヘッダー不足: #{missing_headers.join(', ')}"
end

def parse_date(date)
  Time.parse(date).strftime('%Y-%m-%d')
end

def parse_transfer_flag(transfer)
  transfer_text = transfer.to_s.strip
  return false if transfer_text == '0'
  return true if transfer_text == '1'

  raise ArgumentError, "振替は0または1である必要があります: #{transfer_text}"
end

def parse_price(price)
  price_text = price.to_s.delete(',').strip
  unless /\A-?\d+\z/.match?(price_text)
    raise ArgumentError, "金額（円）が数値ではありません: #{price}"
  end

  number = price_text.to_i
  number.negative? ? number * -1 : number
end

def validate_text_field!(value, field_name)
  return if value.nil?

  if value.match?(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/)
    raise ArgumentError, "#{field_name} に制御文字が含まれています"
  end
end

def validate_row!(row)
  parse_date(row['日付'])
  parse_price(row['金額（円）'])
  parse_transfer_flag(row['振替'])
  TEXT_FIELDS.each { |field_name| validate_text_field!(row[field_name], field_name) }
end

def validate_csv(csv_file_path)
  errors = []
  CSV.open(csv_file_path, headers: true, encoding: 'Shift_JIS:UTF-8') do |csv|
    validate_headers(csv.read.headers || [])
  end

  CSV.foreach(csv_file_path, headers: true, encoding: 'Shift_JIS:UTF-8').with_index(2) do |row, line_no|
    begin
      validate_row!(row)
    rescue StandardError => e
      errors << "line #{line_no}: #{e.message}"
    end
  end

  errors
rescue CSV::MalformedCSVError => e
  ["CSVフォーマットエラー: #{e.message}"]
rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError => e
  ["文字コード変換エラー(Shift_JIS->UTF-8): #{e.message}"]
rescue ArgumentError => e
  [e.message]
end

def format_record_item(item)
  sanitized_item = item.to_s
                       .gsub(/\r\n|\r|\n/, '')
                       .gsub(/\\/) { '\\\\' }
                       .gsub('"', '\"')
  '"%s"'.sub('%s', sanitized_item)
end

def generate_query_values(csv_file_path, values = [])
  CSV.foreach(csv_file_path, headers: true, encoding: 'Shift_JIS:UTF-8') do |row|
    records = [
      format_record_item(parse_date(row['日付'])),
      format_record_item(row['内容']),
      parse_price(row['金額（円）']),
      format_record_item(row['保有金融機関']),
      format_record_item(row['大項目']),
      format_record_item(row['中項目']),
      format_record_item(row['メモ']),
      parse_transfer_flag(row['振替']),
      format_record_item(row['ID']),
    ]

    values << "(#{records.join(', ')})"
  end

  values
end

unless File.exist?(MF_FILE_PATH)
  puts 'MoneyForwardのCSVファイル(mf.csv)が見つかりません'
  exit 1
end

mode = ARGV.first
errors = validate_csv(MF_FILE_PATH)
unless errors.empty?
  puts 'CSVバリデーションエラー:'
  errors.each { |error| puts "  - #{error}" }
  exit 1
end

if mode == 'validate'
  puts 'CSVバリデーションOK'
  exit 0
end

if File.exist?(BQ_SQL_FILE_PATH)
  puts '古いsqlファイルが見つかりました。削除します'
  File.delete(BQ_SQL_FILE_PATH)
end

puts 'sqlファイルを作成します'

base_query = "INSERT INTO #{DATASET_NAME}.#{TABLE_NAME} (date, content, price, financial_institution, root_category, child_category, note, transfer_flag, record_id) VALUES "
values = generate_query_values(MF_FILE_PATH)

sql = "#{base_query}\n#{values.join(",\n")}\n;"
File.open(BQ_SQL_FILE_PATH, 'w') do |file|
  file.puts sql
end

puts '作成完了'
