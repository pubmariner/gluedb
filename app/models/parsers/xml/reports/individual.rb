require 'net/http'

module Parsers::Xml::Reports
  class Individual

    attr_reader :root, :root_level_elements, :person_details, :demographics, :financial_reports, :relationships, :health

    CITIZENSHIP_MAPPING = {
       "U.S. Citizen" => %W(us_citizen naturalized_citizen indian_tribe_member),
       "Lawfully Present" => %W(alien_lawfully_present lawful_permanent_resident),
       "Not Lawfully Present" => %W(undocumented_immigrant not_lawfully_present_in_us)
    }

    def initialize(data_xml = nil)  
      # xml_file = File.open(Rails.root.to_s + "/sample_xmls/individual_address.xml")
      # parser = Nokogiri::XML(xml_file)
      # @root = parser.root
      @root = data_xml
      # build_data_sets_from_xml
    end

    def build_data_sets_from_xml
      build_root_level_elements
      build_person_details
      person_demographics
      person_relationships
      person_financial_reports
      person_health
    end

    def build_root_level_elements
      @root_level_elements = @root.elements.inject({}) do |data, node|
        data[node.name.to_sym] = node.text().strip() if node.elements.count.zero?
        data
      end
    end

    def build_person_details
      @person_details = element_builder(@root.at_xpath("n1:person"))
    end

    def person_demographics
      @demographics = element_builder(@root.at_xpath("n1:person_demographics"))
    end

    def person_financial_reports
      @financial_reports = element_builder(@root.at_xpath("n1:financial_reports"))
    end

    def person_relationships
      @relationships = element_builder(@root.at_xpath("n1:person_relationships"))
    end

    def person_health
      @health = element_builder(@root.at_xpath("n1:person_health"))     
    end

    def id
      person_id = top_level_elements[:id]
      person_id.nil? ? nil : person_id.match(/\w+$/)[0]
    end

    def dob
      parse_date(@demographics[:birth_date])
    end

    def age
      Ager.new(dob).age_as_of(parse_date("2015-1-1"))
    end

    def incarcerated
      @demographics[:is_incarcerated] == 'true' ? 'Yes' : 'No'
    end

    def residency
      return if @addresses[0].nil?
      @addresses[0][:state].strip == 'DC' ? 'D.C. Resident' : 'Not a D.C. Resident'
    end

    def citizenship
      if @demographics[:citizen_status].nil?
        raise "Citizenship status missing for person #{self.name_first} #{self.name_last}"
      end

      citizen_status = @demographics[:citizen_status].split("#")[1]
      CITIZENSHIP_MAPPING.each do |key, value|
        return key if value.include?(citizen_status)
      end
    end

    def tax_status
      return @financial_reports.empty?
      tax_status = @financial_reports[0][:tax_filing_status]
      case tax_status
      when 'non_filer'
        'Non-filer'
      when 'tax_dependent'
        'Tax Dependent'
      when 'tax_filer'
        tax_filer_status
      else
      end
    end

    def tax_filer_status
      filing_status = 'Single'
      relationship = relationships.detect do |relationship| 
        ['spouse', 'life partner'].include?(relationship[:relationship_uri].split("#")[1])
      end
      if relationship
        return if @financial_reports.empty?
        filing_status = @financial_reports[0][:is_tax_filing_together] ? 'Married Filing Jointly' : 'Married Filing Separately'
      end
      filing_status
    end

    def projected_income
      nil # @root.at_xpath("n1:financial/n1:incomes/n1:income/n1:amount").text
    end

    # def employers
    #   @root.xpath("n1:hbx_roles/n1:employee_roles/n1:employee_role").inject([]) do |employers, ele|
    #     employers << ele.at_xpath('n1:employer/n1:id').text
    #   end
    # end

    # def mec
    #   if es_coverage = assistance_eligibility.at_xpath("n1:is_enrolled_for_es_coverage").text
    #     return 'Yes'
    #   end      
    #   benefit = assistance_eligibility.xpath("n1:alternate_benefits/n1:alternate_benefit").detect do |benefit|
    #     Date.strptime(benefit.at_xpath("n1:end_date"), "%Y%m%d") <= Date.parse("2015-1-1")
    #   end
    #   benefit.blank? ? 'No' : 'Yes'      
    # end

    # def income_amt(income)
    #   amount = income.at_xpath("n1:total_income").text.to_f
    #   printf("%.2f", amount)
    # end

    # def yearwise_incomes(year)
    #   incomes = assistance_eligibility.xpath("n1:total_incomes/n1:total_income").inject({}) do |incomes, income|
    #     incomes[income.at_xpath("n1:calendar_year").text] = income_amt(income)
    #   end
    #   incomes[year]
    # end

    # def policies
    #   @root.xpath("n1:hbx_roles/n1:qhp_roles/n1:qhp_role/n1:policies/n1:policy")
    # end

    # def plan_by_coverage_type(type)
    #   policy = policies.detect{|policy| policy.at_xpath("n1:plan/n1:coverage_type").text.split("#")[1] == type}
    #   policy.at_xpath("n1:plan/n1:name").text if policy
    # end

    # def health_plan
    #   plan_by_coverage_type("health")
    # end

    # def dental_plan
    #   plan_by_coverage_type("dental")
    # end

    private

    def extract_collection(node)
      node.elements.inject([]) do |data, node|
        data << extract_properties(node)
      end
    end

    def extract_properties(node)
      node.elements.inject({}) do |data, node|
        data[node.name.to_sym] = (node.elements.count.zero? ? node.text().strip() : element_builder(node))
        data
      end
    end

    def element_builder(node)
      single_element = node.elements.detect{|node| node.elements.count.zero?}
      (single_element.nil? ? extract_collection(node) : extract_properties(node))
    end

    def parse_date(date)
      Date.parse(date)
    end
  end
end
