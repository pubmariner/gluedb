require 'roo'
require 'spreadsheet'

puts "Loading: 2014 Dental Premiums"

YEAR = 2014
dates_by_sheet = [
  Date.new(YEAR, 1, 1)..Date.new(YEAR, 12, 31),
]

def import_spreadsheet(file_path, dates_by_sheet)
  spreadsheet = Roo::Spreadsheet.open(file_path)
  number_sheets = 1

  (0...number_sheets).each do |sheet_index|
    current_sheet = spreadsheet.sheet(sheet_index)

    header = current_sheet.row(1)
    (2..current_sheet.last_row).each do |i|
      plan_details = Hash[[header, current_sheet.row(i)].transpose]
      premiums_to_add = []

      {
        'Ages 0-18' => 0..18,
        'Ages 19-29' => 19..29,
        'Ages 30-45' => 30..45,
        'Ages 46-99' => 46..99
      }.each_pair do |column_name, range|
        range.each do |age|
          cost = plan_details[column_name]
          premium = PremiumTable.new
          premium.rate_start_date = dates_by_sheet[sheet_index].first
          premium.rate_end_date = dates_by_sheet[sheet_index].last
          premium.age = age
          premium.amount = cost

          premiums_to_add << premium
        end
      end

      hios_id = plan_details['Standard Component ID'].gsub(/[[:space:]]/,'')
      plans = Plan.where({:hios_plan_id => /#{hios_id}/, :year => YEAR})
      plans.to_a.each do |plan|
        plan.premium_tables.concat(premiums_to_add)
        plan.save!
      end
    end
  end
end

files = [
  "./db/seedfiles/premium_tables/2014_DCHL_IVL_Dental_Rates.xls",
]

files.each { |f| import_spreadsheet(f, dates_by_sheet) }
