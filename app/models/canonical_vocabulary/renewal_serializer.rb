require "spreadsheet"

module CanonicalVocabulary
  class RenewalSerializer

    CV_API_URL = "http://localhost:3000/api/v1/"

    def initialize(type="assisted")
      if type == "assisted"
        @single = CanonicalVocabulary::Renewals::Assisted.new('single')
        @multiple = CanonicalVocabulary::Renewals::Assisted.new('multiple')
        @super_multiple = CanonicalVocabulary::Renewals::Assisted.new('super')
      else
        @single = CanonicalVocabulary::Renewals::Unassisted.new('single')
        @multiple = CanonicalVocabulary::Renewals::Unassisted.new('multiple')
        @super_multiple = CanonicalVocabulary::Renewals::Unassisted.new('super')
      end
    end

    def serialize(file)
      sheet = Spreadsheet.open("#{Rails.root.to_s}/#{file}").worksheet(0)
      sheet.rows.in_groups_of(10, false) do |group|
        ids = group.map{|x| x[0]}
        serialize_application_groups(ids, type)
      end      
      write_reports
    end

    def serialize_application_groups(group_ids)
      groups_xml = Net::HTTP.get(URI.parse("#{CV_API_URL}application_groups?ids[]=#{group_ids.join("&ids[]=")}&user_token=zUzBsoTSKPbvXCQsB4Ky"))
      root = Nokogiri::XML(groups_xml).root

      root.xpath("n1:application_group").each do |application_group_xml|
        application_group = Parsers::Xml::IrsReports::ApplicationGroup.new(application_group_xml)

        household = application_group_xml.xpath("n1:households/n1:household")[0]
        household = Parsers::Xml::IrsReports::Household.new(household)

        if household.members.empty?
          @single.append_household(household, application_group)
        else
          if household.members.count < 6
            @multiple.append_household(household, application_group)
          else
            @super_multiple.append_household(household, application_group)
          end
        end
      end
    end

    def write_reports
      @single.book.write @single.file
      @multiple.book.write @multiple.file
      @super_multiple.book.write @super_multiple.file
    end
  end
end
