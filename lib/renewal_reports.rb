require "spreadsheet"

class RenewalReports

  # report_type should be "assisted/unassisted"
  def process(options)
    @report_type = options[:report_type] || "assisted"
    generate_application_groups
    CanonicalVocabulary::RenewalSerializer.new(@report_type).serialize("#{@report_type}_groups.xls")
  end

  def generate_application_groups
    policies = Policy.individual_market.send("insurance_#{@report_type}").select{|policy| policy.active_and_renewal_eligible?}
    groups = policies.map{|policy| policy.application_group_id}.compact
    valid_groups = groups.uniq.select{|group_id| valid_application_group?(group_id)}
    generate_spreadsheet(valid_groups, "#{@report_type}_groups.xls")
  end

  def generate_spreadsheet(group_ids, file)
    workbook = Spreadsheet::Workbook.new
    sheet = workbook.create_worksheet :name => 'ids'

    index = 0
    group_ids.each do |id|
      sheet.row(index).concat [id.to_s]
      index += 1
    end
    workbook.write "#{Rails.root.to_s}/#{file}"
  end

  private

  def valid_application_group?(group_id)
    group = ApplicationGroup.find(group_id)
    return false if group.blank?
    valid = true
    group.people.each do |people|
      if people.authority_member.blank?
        valid = false
        break
      end
    end
    return valid
  end
end
