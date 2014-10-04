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
      type_urn.split('#').last.parameterize("_")
    end
=begin
alimony and maintenance
capital gains
dividends
estate and trust income
farming or fishing income
foreign income
interest
lump sum amount
military pay
net self employment income
other
pension/retirement benefits
pensions/retirement benefits
permanent worker's compensation
prizes and awards
rental or royalty income
scholarship payments
social security benefit
supplemental security income
tax-exempt interest
unemployment insurance
wages and salaries
=end

    def frequency_urn
      @parser.at_xpath('./ns1:frequency', NAMESPACES).text
    end

    def frequency
      frequency_urn.split('#').last.gsub("-", "_").parameterize("_")
    end
=begin
Frequencies to map:
bi-weekly
half yearly
monthly
quarterly
weekly
yearly
=end

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
      [dollar_amount,type_urn,start_date,frequency_urn].any?(&:blank?)
    end

    def to_request
      {
        :submitted_date => submitted_date,
        :start_date => start_date,
        :end_date => end_date,
        :kind => type,
        :frequency => frequency,
        :amount_in_cents => amount_in_cents
      }
    end
  end
end
