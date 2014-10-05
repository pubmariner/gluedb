module Parsers::Xml::Cv
  class AlternativeBenefit

    TYPE_MAP = {
      "acf refugee medical assistance" => "acf_refugee_medical_assistance",
      "americorps health benefits" => "americorps_health_benefits",
      "child health insurance plan" => "child_health_insurance_plan",
      "health care for peace corp volunteers" => "health_care_for_peace_corp_volunteers",
      "medicaid" => "medicaid",
      "medicare" => "medicare",
      "medicare part b" => "medicare_part_b",
      "medicare/medicare advantage" => "medicare_advantage",
      "naf health benefit program" => "naf_health_benefit_program",
      "private individual and family coverage" => "private_individual_and_family_coverage",
      "state supplementary payment" => "state_supplementary_payment",
      "tricare" => "tricare",
      "veterans' benefits" => "veterans_benefits"
    }

    def initialize(parser)
      @parser = parser
    end

    def type
      TYPE_MAP[@parser.at_xpath('./ns1:type', NAMESPACES).text]
    end

    def start_date
      first_date('./ns1:start_date')
    end

    def end_date
      first_date('./ns1:end_date')
    end

    def submitted_date
      begin
      Date.parse(@parser.at_xpath('./ns1:submitted_date', NAMESPACES).text).try(:strftime,"%Y%m%d")
      rescue
        nil
      end
    end

    def empty?
      [type].any?(&:blank?)
    end

    def to_request
      {
        :kind => type,
        :end_date => end_date,
        :start_date => start_date,
        :submitted_date => submitted_date
      }
    end
  end
end
