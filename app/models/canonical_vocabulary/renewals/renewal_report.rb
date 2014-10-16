require "spreadsheet"
module CanonicalVocabulary
	module Renewals

      class PolicyProjection
        attr_reader :current, :future_plan_name, :quoted_premium
        def initialize(app_group, coverage_type)
          @coverage_type = coverage_type
          current = app_group.current_insurance_plan(coverage_type)
          future_plan_name = app_group.future_insurance_plan(coverage_type)
          quoted_premium = app_group.quoted_insurance_premium(coverage_type)
        end
      end

		class RenewalReport

      MULTIPLE_LIMIT = 6
      SUPER_LIMIT = 9

      CV_API_URL = "http://localhost:3000/api/v1/"
      
      def append_household(application_group)
        begin
          @application_group = application_group

          individuals = find_many_individuals_by_id(@application_group.applicant_ids)
          @primary = individuals.detect { |i| (i.id == @application_group.primary_applicant_id || individuals.count == 1) }
          raise "Primary Applicant Address Not Present" if @primary.addresses[0].nil?

          @other_members = individuals.reject { |i| i == @primary }

          dental = PolicyProjection.new(@application_group, "dental")
          health = PolicyProjection.new(@application_group, "health")

          if health.current.nil? && dental.current.nil?
            raise "No active health or dental policy"
          end

          @data_set = []
          append_integrated_case_number
          append_notice_date
          append_primary_details
          @other_members.each { |m| append_individual }
          num_blank_members.times { append_blank_member }
          append_aptc if @report_type == "ia"
          append_response_date
          append_policy(health)
          append_post_aptc_premium if @report_type == "ia"
          append_policy(dental)
          append_financials if @report_type == "ia"

          @sheet.row(@row).concat @data_set
          @row += 1         
        rescue Exception  => e
          @renewal_logger.info "#{application_group.id.match(/\w+$/)},#{e.inspect}"
        end
      end

      private

      def find_many_individuals_by_id(ids)
        members_xml = Net::HTTP.get(URI.parse("#{CV_API_URL}people?ids[]=#{ids.join("&ids[]=")}&user_token=zUzBsoTSKPbvXCQsB4Ky"))
        individual_elements = Nokogiri::XML(members_xml).root.xpath("n1:individual")
        individual_elements.map { |i| Parsers::Xml::IrsReports::Individual.new(i) }
      end

      def residency(member)
        member.residency unless member.residency.blank?
        return "No Status" if @primary.addresses[0].nil?
        @primary.addresses[0][:state].strip == "DC" ? "D.C. Resident" : "Not a D.C Resident"
      end

      def append_blank_member
        6.times{ append_blank }
        4.times{ append_blank } if @report_type == "ia"
      end

      def append_integrated_case_number
        @data_set << application_group.integrated_case
      end

      def append_name_of(member)
        @data_set << member.name_first
        @data_set << member.name_last
      end

      def append_notice_date
        @data_set << "10/10/2014" #DATE_OF_NOTICE
      end

      def append_address_of(member)
        @data_set << member.addresses[0][:address_1]
        @data_set << member.addresses[0][:address_2]
        @data_set << member.addresses[0][:apt]
        @data_set << member.addresses[0][:city]
        @data_set << member.addresses[0][:state]
        @data_set << member.addresses[0][:postal_code]
      end

      def append_aptc
        append_blank 
      end

      def append_response_date
        @data_set << "10/10/2014"
      end

      def append_policy(policy)
        @data_set << policy.current.nil? ? nil : policy.current[:plan]
        @data_set << policy.future_plan_name
        @data_set << policy.quoted_premium
      end

      def append_post_aptc_premium
        append_blank  
      end

      def append_financials
        @data_set << @application_group.yearwise_incomes("2014")
        append_blank 
        @data_set << @application_group.irs_consent
      end

      def num_blank_members
        return 0 if @range.nil?
        @range.count - @other_members.count
      end

      def append_individual(individual)
        append_name_of(individual)
        append_other_details(individual)
      end

      def append_primary_details
        append_name_of(@primary)
        append_address_of(@primary)
        other_details_for(@primary)
      end

      def other_details_for(individual)
        @data_set << individual.age
        @data_set << residency(individual)
        @data_set << individual.citizenship

        if @report_type == "ia"
          @data_set << individual.tax_status
          @data_set << individual.mec
          @data_set << @application_group.size
          @data_set << individual.yearwise_incomes("2014")
        end

        @data_set << individual.incarcerated
      end

      def append_blank
        @data_set << nil
      end
    end
  end
end
