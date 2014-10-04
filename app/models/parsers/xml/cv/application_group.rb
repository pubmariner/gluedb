module Parsers::Xml::Cv
  class ApplicationGroup
    def initialize(parser)
      @parser = parser
    end

    def at_xpath(node, xpath)
      node.at_xpath(xpath, NAMESPACES)
    end

    def primary_applicant_id
      node = @parser.at_xpath('./ns1:primary_applicant_id', NAMESPACES)
      (node.nil?)? nil : node.text
    end
    
    def consent_applicant_id
      node = @parser.at_xpath('./ns1:consent_applicant_id', NAMESPACES)
      (node.nil?)? nil : node.text
    end

    def e_case_id
      node = @parser.at_xpath('./ns1:e_case_id', NAMESPACES)
      (node.nil?)? nil : node.text
    end

    def submitted_date
      node = at_xpath(@parser, './ns1:submitted_date')
      (node.nil?)? nil : node.text
    end
    
    def individuals
      results = []

      elements = @parser.xpath('./ns1:applicants/ns1:applicant', NAMESPACES)
      elements.each { |e| results << Individual.new(e) }

      results
    end

    def relationships
      individuals.flat_map { |ind| ind.relationships.reject(&:empty?).map(&:to_request) }
    end

    def to_request
      {
        consent_applicant_id: consent_applicant_id,
        e_case_id: e_case_id,
        primary_applicant_id: primary_applicant_id,
        submission_date: submitted_date,
        people: individuals.map(&:to_request),
        relationships: relationships
      }
    end
  end
end
