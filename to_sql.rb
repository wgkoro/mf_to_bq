# frozen_string_literal: true

require 'csv'
require 'time'

unless File.exist?('./files/mf.csv')
  puts 'MoneyForwardのCSVファイル(mf.csv)が見つかりません'
  exit 1
end

base_query = 'INSERT INTO data_lake.household_budgets (date, content, price, financial_institution, root_category, child_category, note, transfer_flag, record_id) VALUES '
values = []

CSV.foreach('./files/mf.csv', headers: true, encoding: 'Shift_JIS:UTF-8') do |arr|
  date = Time.parse(arr['日付'])
  date_bq = date.strftime('%Y-%m-%d')
  content = arr['内容']

  price = arr['金額（円）'].to_i
  amount = price.negative? ? price * -1 : price

  financial =  arr['保有金融機関']
  root_category = arr['大項目']
  child_category = arr['中項目']
  note = arr['メモ']
  transfer_flag = arr['振替'].to_i.zero? ? false : true
  record_id = arr['ID']

  records = [
    '"%s"'.sub('%s', date_bq),
    '"%s"'.sub('%s', content),
    amount,
    '"%s"'.sub('%s', financial),
    '"%s"'.sub('%s', root_category),
    '"%s"'.sub('%s', child_category),
    '"%s"'.sub('%s', note),
    transfer_flag,
    '"%s"'.sub('%s', record_id),
  ]
  values << "(#{records.join(', ')})"
end


sql_file = './files/bq.sql'
if File.exist?(sql_file)
  puts '古いsqlファイルが見つかりました。削除します'
  File.delete(sql_file)
end

puts 'sqlファイルを作成します'

sql = "#{base_query}\n#{values.join(",\n")}\n;"
File.open(sql_file, 'w') do |file|
  file.puts sql
end

puts '作成完了'
