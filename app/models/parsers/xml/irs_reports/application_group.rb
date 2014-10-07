module Parsers::Xml::IrsReports
  class ApplicationGroup
    
    attr_accessor :individual_policies, :individual_policy_holders, :future_policy_quotes, :individual_policies_details

    def initialize(parser = nil)
      # parser = File.open(Rails.root.to_s + "/application_group_failed.xml")
      # parser = Nokogiri::XML(parser).root

      @root = parser
      @individual_policies = []
      @individual_policy_holders = {}
      @future_policy_quotes = {}
      @individual_policies_details = {}

      @future_plans = {}

      identify_indiv_policies
      policies_details
    end

    def id
      @root.at_xpath("n1:id").text
    end

    def primary_applicant_id
      @root.at_xpath("n1:primary_applicant_id").text
    end

    def size
      applicant_ids.count
    end

    def integrated_case
      @root.at_xpath("n1:e_case_id").text if @root.at_xpath("n1:e_case_id")
    end

    def irs_households
    	@root.xpath("n1:households/n1:household")
    end

    def applicants
      @root.xpath("n1:applicants/n1:applicant")
    end

    def applicant_ids
      @root.xpath("n1:applicants/n1:applicant").map { |e| e.at_xpath("n1:person/n1:id").text.match(/\w+$/)[0]}.uniq
    end

    def yearwise_incomes(year)
      incomes = {}
      irs_households.xpath("n1:total_incomes/n1:total_income").each do |income|
        incomes[income.at_xpath("n1:calendar_year").text] = income.at_xpath("n1:total_income").text
      end
      incomes[year]
    end

    def applicants_xml
      applicants_xml = {}
      applicants.each do |applicant|
        applicants_xml[applicant.at_xpath("n1:person/n1:id").text] = applicant
      end
      applicants_xml
    end

    def identify_indiv_policies
      applicants_xml.each do |app_id, applicant|
        policies = []
        applicant.xpath("n1:hbx_roles/n1:qhp_roles/n1:qhp_role/n1:policies/n1:policy").each do |policy|
          next if policy.at_xpath("n1:employer")
          if policy.at_xpath("n1:enrollees").nil?
            begin_date = Date.strptime(policy.at_xpath("n1:enrollees/n1:enrollee/n1:begin_date").text,'%Y%m%d')
            end_date = Date.strptime(policy.at_xpath("n1:enrollees/n1:enrollee/n1:end_date").text,'%Y%m%d') 
            next if policy_inactive?(begin_date, end_date)
          end
          @individual_policies << policy.at_xpath("n1:id").text
          policies << policy.at_xpath("n1:id").text
        end

        quotes = {}
        applicant.xpath("n1:hbx_roles/n1:qhp_roles/n1:qhp_role/n1:qhp_quotes/n1:qhp_quote").each do |quote|
          coverage = quote.at_xpath("n1:coverage_type").text.split("#")[1]
          quotes[coverage] = quote.at_xpath("n1:rates/n1:rate/n1:rate").text
          if @future_plans[coverage].blank?
            @future_plans[coverage] = future_plan_names_by_hios(quote.at_xpath("n1:qhp_id").text.split("-")[0], coverage)
          end
        end

        @individual_policy_holders[applicant.at_xpath("n1:person/n1:id").text] = policies
        @future_policy_quotes[applicant.at_xpath("n1:person/n1:id").text] = quotes        
      end
    end

    def policies_details     
       policy_ids = @individual_policies.map{|policy| policy.match(/\d+$/)[0]}.uniq
       if policy_ids.count > 10
          raise "Have more than 10 active polices #{policy_ids.inspect}"
       end

       policies_xml = Net::HTTP.get(URI.parse("http://localhost:3000/api/v1/policies?ids[]=#{policy_ids.join("&ids[]=")}&user_token=zUzBsoTSKPbvXCQsB4Ky"))
       root = Nokogiri::XML(policies_xml).root
       root.xpath("n1:policy").each do |policy|
          policy = Parsers::Xml::IrsReports::Policy.new(policy)
          @individual_policies_details[policy.id] = {
             :plan => policy.plan,
             :begin_date => policy.start_date,
             :end_date => policy.end_date,
             :elected_aptc => policy.elected_aptc,
             :coverage_type => policy.coverage_type,
             :qhp_id => policy.qhp_number
          }
       end
    end

    def assisted?
      assisted = false
      @individual_policies_details.each do |id, policy|
        if policy[:elected_aptc].to_i > 0
          assisted = true
          break
        end
      end
      assisted
    end

    def irs_consent
      @root.at_xpath("n1:coverage_renewal_year").text
    end

    def policy_inactive?(begin_date, end_date)
      if begin_date >= Date.parse("2015-1-1") || begin_date == end_date || (!end_date.nil? && end_date < Date.parse("2015-1-1"))
        return true
      end
      false
    end

    def current_insurance_plan(coverage)
      now = Date.today
      @individual_policies_details.each do |id, policy|
        next if policy_inactive?(policy[:begin_date], policy[:end_date])
        if policy[:coverage_type] == coverage
          # && policy[:begin_date] < Date.parse("2015-01-01")
          # if qhp_ids_2015plans.include?(policy[:qhp_id])
          #   # puts "found match...."
          #   raise "2015 policy mapping required for policy QHP ID #{policy[:qhp_id]}"
          # end
          return policy
        end
      end
      nil
    end

    def future_insurance_plan(coverage)
      @future_plans[coverage]
    end

    # {"http://localhost:3000/api/v1/people/53e68e78eb899ad9ca00002b"=>{"health/dental"=>"604.22"}} 
    def quoted_insurance_premium(coverage)
      amount = 0.0
      @future_policy_quotes.each do |individual, quote|
        amount += quote[coverage].to_f
      end
      amount
    end

    def future_plan_names_by_hios(hios_id, coverage)
      hios_ids = {
          "health" => {
          "77422DC0060002" => "Aetna Bronze $20 Copay",
          "77422DC0060004" => "Aetna Bronze Deductible Only HSA Elgible",
          "77422DC0060005" => "Aetna Catastrophic 100%",
          "77422DC0060006" => "Aetna Gold $5 Copay",
          "77422DC0060010" => "Aetna Silver $5 Copay 2750",
          "77422DC0060008" => "Aetna Silver $10 Copay",
          "78079DC0160001" => "BlueCross BlueShield Preferred 500, A Multi-State Plan",
          "78079DC0180001" => "BlueCross BlueShield Preferred 1500, A Multi-State Plan",
          "78079DC0200001" => "BluePreferred HSA Bronze",
          "78079DC0210001" => "BluePreferred Platinum $0",
          "86052DC0400001" => "BlueChoice Silver $2,000",
          "86052DC0400002" => "BlueChoice Gold $0",
          "86052DC0400003" => "BlueChoice Gold $1,000",
          "86052DC0400004" => "BlueChoice Young Adult $6,600",
          "86052DC0410001" => "BlueChoice HSA Bronze $4,000",
          "86052DC0410002" => "BlueChoice HSA Bronze $6,000",
          "86052DC0410003" => "BlueChoice HSA Silver $1,300",
          "86052DC0420001" => "BlueChoice Plus Bronze $5,500",
          "86052DC0420002" => "BlueChoice Plus Silver $2,500",
          "86052DC0430001" => "HealthyBlue Gold $1,500",
          "86052DC0430002" => "HealthyBlue Platinum $0",
          "94506DC0390001" => "KP DC Platinum 0/10/Dental/Ped Dental",
          "94506DC0390002" => "KP DC Gold 0/20/Dental/Ped Dental",
          "94506DC0390003" => "KP DC Gold 1000/20/Dental/Ped Dental",
          "94506DC0390004" => "KP DC Silver 1500/30/Dental/Ped Dental",
          "94506DC0390005" => "KP DC Silver 2500/30/Dental/Ped Dental",
          "94506DC0390006" => "KP DC Silver 1750/25%/HSA/Dental/Ped Dental",
          "94506DC0390007" => "KP DC Bronze 4500/50/Dental/Ped Dental",
          "94506DC0390008" => "KP DC Catastrophic 6600/0/Dental/ Ped Dental",
          "94506DC0390009" => "KP DC Bronze 4500/50/HSA/Dental/Ped Dental",
          "94506DC0390010" => "KP DC Bronze 5000/30%/HSA/Dental/Ped Dental"
          },
          "dental" => {
            "78079DC0320002" => "BlueDental Preferred - Low Option",
            "95051DC0020003" => "BESTOne Dental Advantage-High",  
            "95051DC0020004" => "BESTOne Dental Plus-High",  
            "95051DC0020005" => "BESTOne Dental Plus-Low",  
            "95051DC0020006" => "BESTOne Dental Basic-Low",  
            "81334DC0010004" => "Delta Dental Individual & Family Delta Dental PPO Preferred Plan for Families", 
            "81334DC0010006" => "Delta Dental Individual & Family Delta Dental PPO Basic Plan for Families",  
            "81334DC0030004" => "Delta Dental Individual & Family DeltaCare USA Preferred Plan for Families",  
            "81334DC0030006" => "Delta Dental Individual & Family DeltaCare USA Basic Plan for Families",  
            "92479DC0010002" => "Select Plan",  
            "92479DC0020002" => "Access PPO",  
            "96156DC0010004" => "Dentegra Dental PPO Family Preferred Plan",  
            "96156DC0010006" => "Dentegra Dental PPO Family Basic Plan"
          }
        } 
      hios_ids[coverage][hios_id]
    end
  end
end
