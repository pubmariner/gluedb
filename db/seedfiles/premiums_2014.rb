require 'roo'
require 'spreadsheet'

# def clean_old_premiums
#   Plan.collection.where.update({"$set" => {"premium_tables"=> []}}, {:multi => true})
# end

puts "Loading: 2014 Premiums"

dates_by_sheet = [
  Date.new(2014, 1, 1)..Date.new(2014, 12, 31),
  Date.new(2014, 1, 1)..Date.new(2014, 3, 31),
  Date.new(2014, 4, 1)..Date.new(2014, 6, 30),
  Date.new(2014, 7, 1)..Date.new(2014, 9, 30),
  Date.new(2014, 10, 1)..Date.new(2014, 12, 31)
]

def import_spreadsheet(file_path, dates_by_sheet)
  spreadsheet = Roo::Spreadsheet.open(file_path)
  number_sheets = spreadsheet.sheets.count

  (0...number_sheets).each do |sheet_index|
    current_sheet = spreadsheet.sheet(sheet_index)

    header = current_sheet.row(1)
    (2..current_sheet.last_row).each do |i|
      plan_details = Hash[[header, current_sheet.row(i)].transpose]
      premiums_to_add = []

      (0..20).each do |age|
        cost = plan_details['0-20']
        premium = PremiumTable.new
        premium.rate_start_date = dates_by_sheet[sheet_index].first
        premium.rate_end_date = dates_by_sheet[sheet_index].last
        premium.age = age
        premium.amount = cost

        premiums_to_add << premium
      end

      (21..63).each do |age|
        cost = plan_details[age.to_f]
        premium = PremiumTable.new
        premium.rate_start_date = dates_by_sheet[sheet_index].first
        premium.rate_end_date = dates_by_sheet[sheet_index].last
        premium.age = age
        premium.amount = cost

        premiums_to_add << premium
      end

      (64..120).each do |age|
        cost = plan_details["64 +"]
        premium = PremiumTable.new
        premium.rate_start_date = dates_by_sheet[sheet_index].first
        premium.rate_end_date = dates_by_sheet[sheet_index].last
        premium.age = age
        premium.amount = cost

        premiums_to_add << premium
      end

      hios_id = plan_details['Standard Component ID'].gsub(/[[:space:]]/,'')
      plans = Plan.where({:hios_plan_id => /#{hios_id}/})
      plans.to_a.each do |plan|
        plan.premium_tables.concat(premiums_to_add)
        plan.save!
      end
    end
  end
end

files = [
  "./db/seedfiles/premium_tables/2014_DCHL_Rates_12_13_14_INDVandSHOPthruQ2.xlsx",
  "./db/seedfiles/premium_tables/2014_DCHL_Rates_IVL_and_SHOP_Q1_thru_Q4.xlsx"
]

# clean_old_premiums
files.each { |f| import_spreadsheet(f, dates_by_sheet) }
