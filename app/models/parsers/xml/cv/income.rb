module Parsers::Xml::Cv
  class Income
    def initialize(parser)
      @parser = parser
    end

    def dollar_amount
      @parser.at_xpath('./n1:amount', NAMESPACES).text.to_f.round(2)
    end

    def income_type_urn
      @parser.at_xpath('./n1:income_type', NAMESPACES).text
    end

    def income_type
      income_type_urn.split('#').last
    end

    def frequency_urn
      @parser.at_xpath('./n1:frequency', NAMESPACES).text
    end

    def frequency
      frequency_urn.split('#').last
    end

    def start_date
      Date.parse(@parser.at_xpath('./n1:start_date', NAMESPACES).text)
    end

    def end_date
      Date.parse(@parser.at_xpath('./n1:end_date', NAMESPACES).text)
    end

    def evidence_flag
      @parser.at_xpath('./n1:evidence_flag', NAMESPACES).text == 'true'
    end

    def reported_date
      Date.parse(@parser.at_xpath('./n1:reported_date', NAMESPACES).text)
    end

    def reported_by
      @parser.at_xpath('./n1:reported_by', namespaces).text
    end
  end
end
