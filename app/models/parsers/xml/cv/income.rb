module Parsers::Xml::Cv
  class Income
    include NodeUtils
    def initialize(parser)
      @parser = parser
    end

    def dollar_amount
      @parser.at_xpath('./ns1:amount', NAMESPACES).text.to_f.round(2)
    end

    def type_urn
      @parser.at_xpath('./ns1:type', NAMESPACES).text
    end

    def type
      type_urn.split('#').last
    end

    def frequency_urn
      @parser.at_xpath('./ns1:frequency', NAMESPACES).text
    end

    def frequency
      frequency_urn.split('#').last
    end

    def start_date
      first_date('./ns1:start_date')
    end

    def end_date
      first_date('./ns1:end_date')
    end

    def submitted_date
      first_date('./ns1:submitted_date')
    end

    def amount_in_cents
      (dollar_amount * 100).to_i
    end

    def empty?
      [dollar_amount,type,start_date,frequency].any?(&:blank?)
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
