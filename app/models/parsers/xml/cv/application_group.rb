module Parsers::Xml::Cv
  class ApplicationGroup
    def initialize(parser)
      @parser = parser
    end

    def primary_applicant_id
      node = @parser.at_xpath('./ns1:primary_applicant_id', NAMESPACES)
      (node.nil?)? nil : node.text
    end
    
    def consent_applicant_id
      node = @parser.at_xpath('./ns1:consent_applicant_id', NAMESPACES).text
      (node.nil?)? nil : node.text
    end

    def e_case_id
      node = @parser.at_xpath('./ns1:e_case_id', NAMESPACES).text 
      (node.nil?)? nil : node.text
    end
    
    def applicants
      results = []

      elements = @parser.xpath('./ns1:applicants/ns1:applicant', NAMESPACES)
      elements.each { |e| results << Individual.new(e) }

      results
    end
  end
end
