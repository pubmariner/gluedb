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
        # puts "======================"
        # puts application_group.primary_applicant_id.inspect
 begin
				@household_address = []
				@member_details = {:members => []}
        # @household = household
        @application_group = application_group

				populate_member_details
        # puts @member_details.inspect


				data_set  = [application_group.integrated_case, "10/10/2014"]
				data_set += @member_details[:primary].slice!(0..1)
				data_set += @household_address
        data_set += @member_details[:primary]
        data_set += @member_details[:members]

        # APTC
        data_set += [nil] if @report_type == "ia"
        data_set += ["10/10/2014"]
        data_set += policy_details

        # puts @household_address.inspect
        # puts policy_details.inspect

				@sheet.row(@row).concat data_set
				@row += 1
rescue Exception  => e
  @sheet2.row(@row2).concat [application_group.integrated_case, e.inspect]
  @row2 += 1
end
			end

      def populate_member_details
				members_xml = Net::HTTP.get(URI.parse("#{CV_API_URL}people?ids[]=#{@application_group.applicant_ids.join("&ids[]=")}&user_token=zUzBsoTSKPbvXCQsB4Ky"))
        root = Nokogiri::XML(members_xml).root
        member_count = 0
        individual_count = root.xpath("n1:individual").count

        primary_processed = false
        # Household Address should be popoulated before member details
        root.xpath("n1:individual").each do |member|
          individual = Parsers::Xml::IrsReports::Individual.new(member)
          break if !@household_address.empty? && primary_processed
          if individual.id == @application_group.primary_applicant_id || individual_count = 1
            @household_address = household_address(individual)
            primary_processed = true
          else
            @household_address = household_address(individual) if @household_address.empty?
          end
        end

        root.xpath("n1:individual").each do |member|
          individual = Parsers::Xml::IrsReports::Individual.new(member)
          if individual.id == @application_group.primary_applicant_id || individual_count = 1
            @member_details[:primary] = individual_details(individual)
          else
            member_count += 1 
            @member_details[:members] += individual_details(individual)
          end
        end

        if @range
        	(@range.count - member_count).times do
        		@member_details[:members] += fill_blank_member
        	end
        end
			end

			def fill_blank_member
        data = []
				5.times{ data << nil}
				4.times{ data << nil} if @report_type == "ia"
				data << nil

				data
			end

      def residency(member)
        if member.residency.blank?
          return "No Status"if @household_address.empty?
          if @household_address[-2].strip == "DC" ? 
            return "D.C. Resident"
          else
            return "Not a D.C Resident"
          end
        else
          return member.residency
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
      			member.projected_income
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