module Parsers::Xml::Cv
  class Income
    def initialize(parser)
      @parser = parser
    end

    def dollar_amount
      @parser.at_xpath('./n1:amount', NAMESPACES).text.to_f.round(2)
    end

    def type_urn
      @parser.at_xpath('./n1:type', NAMESPACES).text
    end

    def type
      income_type_urn.split('#').last
    end

    def frequency_urn
      @parser.at_xpath('./n1:frequency', NAMESPACES).text
    end

    def frequency
      frequency_urn.split('#').last
    end

    def start_date
      Date.parse(@parser.at_xpath('./n1:start_date', NAMESPACES).text).try(:strftime,"%Y%m%d")
    end

    def end_date
      node = @parser.at_xpath('./n1:end_date', NAMESPACES)
      (node.nil?) ? nil : Date.parse(node.text).try(:strftime,"%Y%m%d")
    end

    def submitted_date
      Date.parse(@parser.at_xpath('./n1:submitted_date', NAMESPACES).text).try(:strftime,"%Y%m%d")
    end

    def amount_in_cents
      (dollar_amount * 100).to_i
    end

    def to_request
      {
        :submitted_date => submitted_date,
        :start_date => start_date,
        :end_date => end_date,
        :type => type,
        :frequency => frequency,
        :amount_in_cents => amount_in_cents
      }
    end
  end
end
