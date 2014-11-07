module Parsers::Xml::Enrollment
  class IndividualChangeRequest < ChangeRequest
    def initialize(xml)
      super(xml)
      @enrollment_group = @payload.at_xpath('./ins:individual_market_enrollment_group', @namespaces)
      @plan = @enrollment_group.at_xpath('./ins:plan', @namespaces)
    end

    def hios_plan_id
      @plan.at_xpath('./pln:plan/pln:hios_plan_id', @namespaces).text
    end

    def plan_year
      subscriber = Parsers::Xml::Enrollment::IndividualEnrollee.new(@enrollment_group.xpath('./ins:subscriber', @namespaces))
      begin
      Date.parse(subscriber.rate_period_date).year
      rescue
        subscriber.rate_period_date.year
      end
    end

    def premium_amount_total
      @plan.at_xpath('./ins:premium_amount_total', @namespaces).text.to_f
    end

    def enrollees
      enrollees = @enrollment_group.xpath('./ins:subscriber | ./ins:member', @namespaces)
      enrollees.collect { |e| Parsers::Xml::Enrollment::IndividualEnrollee.new(e) }
    end

    def credit
      @plan.at_xpath('./ins:aptc_amount', @namespaces).text.to_f
    end

    def total_responsible_amount
      @plan.at_xpath('./ins:total_responsible_amount', @namespaces).text.to_f
    end
  end
end
