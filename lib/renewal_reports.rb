require "spreadsheet"

class RenewalReports

  def generate
    # generate_assisted_groups
    # puts "Generated assisted application groups spreadsheet"
    # generate_unassisted_groups
    # puts "Generated unassisted application groups spreadsheet"
    # CanonicalVocabulary::RenewalSerializer.new("assisted").serialize("assisted_groupids.xls")
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
    puts "assisted policies --- #{policies.count}"
    ids = policies.map{|policy| policy.application_group_id}.uniq
    valid_ids = ids.select{|group_id| valid_application_group?(group_id)}
    puts "assisted application groups --- #{valid_ids.count}"
    generate_excel(valid_ids, "assisted_groupids.xls")
  end

  def generate_unassisted_groups
    policies = Policy.individual_market.unassisted.select{|policy| policy.active_and_renewal_eligible?}
    puts "unassisted policies --- #{policies.count}"
    ids = policies.map{|policy| policy.application_group_id}.compact.uniq
    valid_ids = ids.select{|group_id| valid_application_group?(group_id)}
    puts "unassisted application groups --- #{valid_ids.count}"
    generate_excel(valid_ids, "unassisted_groupids.xls")
  end

  def valid_application_group?(group_id)
     group = ApplicationGroup.find(group_id)
     return false if group.nil?

     group.people.each do |people|
       return false if people.authority_member.blank?
     end
     true
  end
end
