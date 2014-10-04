module Parsers::Xml::Cv
  class AlternativeBenefit
    def initialize(parser)
      @parser = parser
    end

    def type_urn
      @parser.at_xpath('./ns1:type', NAMESPACES).text
    end

    def type
      type_urn.split('#').last
    end
=begin
acf refugee medical assistance
americorps health benefits
child health insurance plan
health care for peace corp volunteers
medicaid
medicare
medicare part b
medicare/medicare advantage
naf health benefit program
private individual and family coverage
state supplementary payment
tricare
veterans' benefits
=end

    def start_date
      begin
        Date.parse(@parser.at_xpath('./ns1:start_date', NAMESPACES).text).try(:strftime,"%Y%m%d")
      rescue
        nil
      end
    end

    def end_date
      node = @parser.at_xpath('./ns1:end_date', NAMESPACES)
      begin
        (node.nil?) ? nil : Date.parse(node.text).try(:strftime,"%Y%m%d")
      rescue
        nil
      end
    end

    def submitted_date
      begin
      Date.parse(@parser.at_xpath('./ns1:submitted_date', NAMESPACES).text).try(:strftime,"%Y%m%d")
      rescue
        nil
      end
    end

    def empty?
      [type,start_date,end_date].any?(&:blank?)
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
