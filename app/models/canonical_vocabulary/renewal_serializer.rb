require "spreadsheet"

module CanonicalVocabulary
  class RenewalSerializer

    CV_API_URL = "http://localhost:3000/api/v1/"

    def initialize
      @single_ia = CanonicalVocabulary::Renewals::Assisted.new('single')
      @multiple_ia = CanonicalVocabulary::Renewals::Assisted.new('multiple')
      @super_multiple_ia = CanonicalVocabulary::Renewals::Assisted.new('super')

      @single_uqhp = CanonicalVocabulary::Renewals::Unassisted.new('single')
      @multiple_uqhp = CanonicalVocabulary::Renewals::Unassisted.new('multiple')
      @super_multiple_uqhp = CanonicalVocabulary::Renewals::Unassisted.new('super')
    end

    def serialize
      page_number = 1
      count = 15

      while(count == 15) do
        # households_xml = Net::HTTP.get(URI.parse("#{CV_API_URL}households?user_token=zUzBsoTSKPbvXCQsB4Ky&page=#{page_number}"))        
        # root = Nokogiri::XML(households_xml).root

        groups_xml = Net::HTTP.get(URI.parse("#{CV_API_URL}application_groups?user_token=zUzBsoTSKPbvXCQsB4Ky&page=#{page_number}"))
        root = Nokogiri::XML(groups_xml).root

        count = root.xpath("n1:application_group").count

        # root.xpath("n1:household").each do |household|
        root.xpath("n1:application_group").each do |application_group_xml|
          application_group = Parsers::Xml::IrsReports::ApplicationGroup.new(application_group_xml)

          # Criteria
          # Individual market + End date
          # Assisted Vs Unassisted (elected aptc)

          next if application_group.individual_policies.empty?
          next unless application_group.has_renewal_policies?

          # household_count = application_group.xpath("n1:households/n1:household").count
          household = application_group_xml.xpath("n1:households/n1:household")[0]
          household = Parsers::Xml::IrsReports::Household.new(household)
 
          if application_group.assisted?
            if household.members.empty?
              @single_ia.append_household(household, application_group)
            elsif household.members.count < 6
              @multiple_ia.append_household(household, application_group)
            else
              @super_multiple_ia.append_household(household, application_group)
            end
          else           
            if household.members.empty?
              @single_uqhp.append_household(household, application_group)
            elsif household.members.count < 6
              @multiple_uqhp.append_household(household, application_group)
            else
              @super_multiple_uqhp.append_household(household, application_group)
            end
          end
        end

        puts "processed-----#{page_number*15}"
        break if page_number == 10
        page_number += 1
      end

      # write_reports
    end

    def write_reports
      @single_ia.book.write @single_ia.file
      @multiple_ia.book.write @multiple_ia.file
      @super_multiple_ia.book.write @super_multiple_ia.file

      @single_uqhp.book.write @single_uqhp.file
      @multiple_uqhp.book.write @multiple_uqhp.file
      @super_multiple_uqhp.book.write @super_multiple_uqhp.file
    end
  end
end
