require "spreadsheet"
module CanonicalVocabulary
	module Renewals
		class RenewalReport

      MULTIPLE_LIMIT = 6
      SUPER_LIMIT = 9

      IA_PRIMARY_COLUMNS = [
        "IC Number",
        "Date of Notice",	
        "Primary First",
        "Primary Last",
        "Primary Street 1",
        "Primary Street 2",
        "Apt",
        "City",
        "State",
        "Zip",
        "Age 1",
        "Residency 1",
        "Citizenship 1",	
        "Tax Status 1",
        "MEC 1",
        "HH Size 1",
        "Projected Income 1",
        "Incarcerated 1"
      ]

      UQHP_PRIMARY_COLUMNS = [
        "IC Number",
        "Date of Notice",	
        "Primary First",
        "Primary Last",
        "Primary Street 1",
        "Primary Street 2",
        "Apt",
        "City",
        "State",
        "Zip",
        "Age 1",
        "Residency 1",
        "Citizenship 1",
        "Incarcerated 1"
      ]	

      IA_POLICY_COLUMNS = [		
        "APTC",
        "Response Date",
        "2014 Health Plan",	
        "2015 Health Plan",
        "2015 Health Plan Premium",
        "HP Premium After APTC",
        "2014 Dental Plan",	
        "2015 Dental Plan",
        "2015 Dental Plan Premium",
        "HH Total Income",	
        "CSR Eligibility",
        "IRS Consent"
      ]

      UQHP_POLICY_COLUMNS = [		
        "Response Date",
        "2014 Health Plan",	
        "2015 Health Plan",
        "2015 Health Plan Premium",
        "2014 Dental Plan",	
        "2015 Dental Plan",
        "2015 Dental Plan Premium"
      ]

      CV_API_URL = "http://localhost:3000/api/v1/"
      
      # repeated for each IA household member
      def ia_member_columns(range)
      	range.inject([]) do |columns, n|
      		columns += [
      			"P#{n} First",
      			"P#{n} Last",
      			"Age #{n}",
      			"Residency #{n}",
      			"Citizenship #{n}",
      			"Tax Status #{n}",
      			"MEC #{n}",
      			"HH Size #{n}",
      			"Projected Income #{n}",
      			"Incarcerated #{n}"
      		]
      	end
      end
      
      # repeated for each Unassisted Household member
      def uqhp_member_columns(range)
      	range.inject([]) do |columns, n|
      		columns += [
      			"P#{n} First",
      			"P#{n} Last",
      			"Age #{n}",
      			"Residency #{n}",
      			"Citizenship #{n}",
      			"Incarcerated #{n}"
      		]
      	end
      end  

      def append_household(application_group)
        begin
          @household_address = []
          @member_details = {:members => []}
          @application_group = application_group

          populate_member_details

          data_set  = [application_group.integrated_case, "10/10/2014"]
          data_set += @member_details[:primary].slice!(0..1) #last and first name
          data_set += @household_address
          data_set += @member_details[:primary]
          data_set += @member_details[:members]

          # APTC
          data_set += [nil] if @report_type == "ia"
          data_set += ["10/10/2014"]
          data_set += policy_details
          if @report_type == "ia"
            data_set += [@application_group.yearwise_incomes("2014"),nil, @application_group.irs_consent]
          end
          @sheet.row(@row).concat data_set
          @row += 1         
        rescue Exception  => e
          @renewal_logger.info "#{application_group.id.match(/\w+$/)},#{e.inspect}"
        end
      end

      def populate_member_details
        members_xml = Net::HTTP.get(URI.parse("#{CV_API_URL}people?ids[]=#{@application_group.applicant_ids.join("&ids[]=")}&user_token=zUzBsoTSKPbvXCQsB4Ky"))
        individual_elements = Nokogiri::XML(members_xml).root.xpath("n1:individual")

        # primary_processed = false
        # Household Address should be popoulated before member details

        individuals = individual_elements.map { |i| Parsers::Xml::IrsReports::Individual.new(i) }

        primary = individuals.detect { |i| (i.id == @application_group.primary_applicant_id || individuals.count == 1) }
        @household_address = household_address(primary)

        if @household_address.empty?
          raise "Primary Applicant Address Not Present"
        end

        @member_details[:primary] = individual_details(primary)
        other_members = individuals.reject { |i| i == primary }
        @member_details[:members] = other_members.inject([]) { |result, i| result += individual_details(i) }

        return if @range.nil?
        (@range.count - other_members.count).times{ @member_details[:members] += fill_blank_member}
      end

      def fill_blank_member
        data = []
        6.times{ data << nil}
        4.times{ data << nil} if @report_type == "ia"
        data
      end

      def residency(member)
        if member.residency.blank?
          return "No Status"if @household_address.empty?
          @household_address[-2].strip == "DC" ? "D.C. Resident" : "Not a D.C Resident"
        else
          member.residency
        end
      end

      def individual_details(member)
      	data = [
      		member.name_first,
      		member.name_last,
      		member.age,
         residency(member),
         member.citizenship
       ]

       if @report_type == "ia"
        data += [
         member.tax_status,
         member.mec,
         @application_group.size,
         member.yearwise_incomes("2014")
       ]
     end

     data << member.incarcerated
   end

   def policy_details
    if @application_group.current_insurance_plan("health").nil? && @application_group.current_insurance_plan("dental").nil?
      raise "No active health or dental policy"
    end

    health_plan = @application_group.current_insurance_plan("health")
    policy = [
     health_plan.nil? ? nil : health_plan[:plan],
     @application_group.future_insurance_plan("health"),
     @application_group.quoted_insurance_premium("health")
   ]
        # HP Premium After APTC 
        policy += [nil] if @report_type == "ia" 

        dental_policy = @application_group.current_insurance_plan("dental")
        policy += [ 
         dental_policy.blank? ? nil : dental_policy[:plan],
         @application_group.future_insurance_plan("dental"),
         @application_group.quoted_insurance_premium("dental")
       ]
     end

     def household_address(member)
       address = member.addresses[0]
       return [] if address.nil?
       [
         address[:address_1],
         address[:address_2],
         address[:apt],
         address[:city],
         address[:state],
         address[:postal_code]
       ]
     end
   end
 end
end
