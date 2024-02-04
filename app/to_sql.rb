# frozen_string_literal: true

require 'csv'
require 'time'

DATASET_NAME = ENV['DATASET_NAME']
TABLE_NAME = ENV['TABLE_NAME']

MF_FILE_PATH = './files/mf.csv'.freeze
BQ_SQL_FILE_PATH = './files/bq.sql'.freeze

def parse_date(date)
  Time.parse(date).strftime('%Y-%m-%d')
end

def parse_transfer_flag(transfer)
  transfer.to_i.zero? ? false : true
end

def parse_price(price)
  number = price.to_i
  number.negative? ? number * -1 : number
end

def format_record_item(item)
  '"%s"'.sub('%s', item)
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
