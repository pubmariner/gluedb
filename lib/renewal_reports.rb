require "spreadsheet"

class RenewalReports

  def generate
    generate_assisted_groups
    puts "Generated assisted application groups spreadsheet"
    generate_unassisted_groups
    puts "Generated unassisted application groups spreadsheet"
    CanonicalVocabulary::RenewalSerializer.new("assisted").serialize("assisted_groupids.xls")
    CanonicalVocabulary::RenewalSerializer.new("unassisted").serialize("unassisted_groupids.xls")
  end

  def generate_excel(group_ids, file)
    workbook = Spreadsheet::Workbook.new
    sheet = workbook.create_worksheet :name => 'ids'

    index = 0
    group_ids.each do |id|
      sheet.row(index).concat [id.to_s]
      index += 1
    end

    workbook.write "#{Rails.root.to_s}/#{file}"
  end

  def generate_assisted_groups
    policies = Policy.individual_market.insurance_assisted.select{|policy| policy.active_and_renewal_eligible?}
    puts "assisted policies --- #{polices.count}"
    ids = policies.map{|policy| policy.household.application_group_id}.uniq
    puts "assisted application groups --- #{ids.count}"
    generate_excel(ids, "assisted_groupids.xls")
  end

  def generate_unassisted_groups
    polices = Policy.individual_market.unassisted.select{|policy| policy.active_and_renewal_eligible?}
    puts "unassisted policies --- #{polices.count}"
    ids = polices.map{|policy| policy.household.application_group_id}.uniq
    puts "unassisted application groups --- #{ids.count}"
    generate_excel(ids, "unassisted_groupids.xls")
  end
end