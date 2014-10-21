module Parsers::Xml::Enrollment
  class Enrollee
    def initialize(parser)
      @parser = parser
      @coverage = @parser.at_xpath('./ins:coverage', NAMESPACES)
    end

    def birth_date
      text_date = @parser.at_xpath('./ins:DOB', NAMESPACES).text
      Date.parse(text_date)
    end

    def benefit_begin_date
      Date.parse(@coverage.at_xpath('./ins:benefit_begin_date', NAMESPACES).text)
    end

    def rate_period_date
      raise NotImplementedError
    end

    def premium_amount
      @coverage.at_xpath('./ins:premium_amount', NAMESPACES).text.to_f
    end

    def premium_amount=(amt)
      node = @coverage.at_xpath('./ins:premium_amount', NAMESPACES)
      node.content = amt
    end

    def first_name
      @parser.at_xpath('./con:person/con:name_first', NAMESPACES).text
    end

    def last_name
      @parser.at_xpath('./con:person/con:name_last', NAMESPACES).text
    end

    def name
      [first_name, last_name].join(' ')
    end

    def age
      Ager.new(birth_date).age_as_of(benefit_begin_date)
    end

    def hbx_member_id
      @parser.at_xpath('./ins:exchange_member_id', NAMESPACES).text
    end

    def rel_code
      @parser.at_xpath('./ins:individual_relationship_code', NAMESPACES).text.downcase
    end
  end
end
