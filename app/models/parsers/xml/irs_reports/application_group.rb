module Parsers::Xml::IrsReports
  class ApplicationGroup
    
    attr_accessor :individual_policies, :individual_policy_holders

    def initialize(parser = nil)
      # parser = File.open(Rails.root.to_s + "/application_group.xml")
      # parser = Nokogiri::XML(parser)

      @root = parser
      @individual_policies = []
      @individual_policy_holders = {}
      @policies_details = {}
      identify_indiv_policies
      policies_details
    end

    def integrated_case
      nil # @root.at_xpath("n1:e_case_id").text
    end

    def irs_households
    	@root.xpath("n1:households/n1:household")
    end

    def applicants
      @root.xpath("n1:applicants/n1:applicant")
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
          @individual_policies << policy.at_xpath("n1:id").text
          policies << policy.at_xpath("n1:id").text
        end
        @individual_policy_holders[applicant.at_xpath("n1:person/n1:id").text] = policies
      end
    end

    def policies_details
       policy_ids = @individual_policies.map{|policy| policy.match(/\d+$/)[0]}.uniq
       policies_xml = Net::HTTP.get(URI.parse("http://localhost:3000/api/v1/policies?ids[]=#{policy_ids.join("&ids[]=")}&user_token=zUzBsoTSKPbvXCQsB4Ky"))
       root = Nokogiri::XML(policies_xml).root

       root.xpath("n1:policy").each do |policy|
          policy = Parsers::Xml::IrsReports::Policy.new(policy)
          @policies_details[policy.id] = {
             :plan => policy.plan,
             :begin_date => policy.start_date,
             :end_date => policy.end_date,
             :elected_aptc => policy.elected_aptc,
             :coverage_type => policy.coverage_type
          }
       end
    end

    def assisted?
      @policies_details.each do |id, policy|
        return true if policy[:elected_aptc].to_i > 0
      end
      false
    end

    def insurance_plan_2014(coverage)
      @policies_details.each do |id, policy|
        if policy[:coverage_type] == coverage && policy[:begin_date] < Date.parse("2015-01-01")
          return policy[:plan]
        end
      end
      nil
    end

    def insurance_plan_2015(coverage)
      @policies_details.each do |id, policy|
        if policy[:coverage_type] == coverage && policy[:begin_date] >= Date.parse("2015-01-01")
          return policy[:plan]
        end
      end
      nil
    end

    def health_plan_premium_2015
      nil
    end

    def dental_plan_premium_2015
      nil
    end
  end
end
