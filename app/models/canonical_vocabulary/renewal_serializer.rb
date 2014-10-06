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
      current = 1
      ids = []
      limit = sheet.rows.count
      @logger = Logger.new("#{Rails.root}/log/renewals.log")

      sheet.each do |row|
        next if row[0] == "5431d396eb899ad6b2000510"
        ids << row[0]
        if ids.size == 5 || current == limit
          serialize_groupids(ids)
          ids =[]
          puts "----processed #{current} application groups"
        end    
        break if current == 5000
        current += 1
      end

      write_reports
    end

    def serialize_groupids(group_ids)
      puts "processing......"
      puts group_ids.inspect
      begin
        groups_xml = Net::HTTP.get(URI.parse("#{CV_API_URL}application_groups?ids[]=#{group_ids.join("&ids[]=")}&user_token=zUzBsoTSKPbvXCQsB4Ky"))
        root = Nokogiri::XML(groups_xml).root
        root.xpath("n1:application_group").each do |application_group_xml|
        # parser = File.open(Rails.root.to_s + "/application_group.xml")
        # application_group_xml = Nokogiri::XML(parser).root
        application_group = Parsers::Xml::IrsReports::ApplicationGroup.new(application_group_xml)
        # household = application_group_xml.xpath("n1:households/n1:household")[0]
        # household = Parsers::Xml::IrsReports::Household.new(household)
        if application_group.size == 1
          @single.append_household(application_group)
        else
          if application_group.size <= 6
            @multiple.append_household(application_group)
          else
            @super_multiple.append_household(application_group)
          end
        end
        end

      rescue Exception  => e
        @logger.info group_ids.join(",")
      end
    end

    def write_reports
      @single.book.write @single.file
      @multiple.book.write @multiple.file
      @super_multiple.book.write @super_multiple.file
    end
  end
end
