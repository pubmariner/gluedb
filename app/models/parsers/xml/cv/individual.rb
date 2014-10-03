module Parsers::Xml::Cv
  class Individual
    def initialize(parser)
      @parser = parser
    end

    def person
      Person.new(@parser.at_xpath('./ns1:financial/ns1:person', NAMESPACES))
    end

    def is_state_resident
      node = @parser.at_xpath('./ns1:is_state_resident', NAMESPACES)
      (node.nil?)? nil : node.text.downcase == 'true'
    end

    def citizen_status_urn
      node = @parser.at_xpath('./ns1:citizen_status', NAMESPACES)
      (node.nil?)? nil : node.text
    end

    def citizen_status
      urn = citizen_status_urn
      (urn.nil?) ? nil : urn.split('#').last
    end

    def is_incarcerated
      node = @parser.at_xpath('./ns1:is_incarcerated', NAMESPACES)
      (node.nil?)? nil : node.text.downcase == 'true'
    end

    def assistance_eligibilities
      results = []
      elements = @parser.xpath('./ns1:assistance_eligibilities/ns1:assistance_eligibility', NAMESPACES)
      elements.each { |i| results << AssistanceEligibility.new(i) }
      results
    end
  end
end
