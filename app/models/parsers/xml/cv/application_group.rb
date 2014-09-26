module Parsers::Xml::Cv
  class ApplicationGroup
    def initialize(parser)
      @parser = parser
    end
    
    def applicants
      results = []

      elements = @parser.xpath('./ns1:applicants/ns1:applicant', NAMESPACES)
      elements.each { |e| results << Individual.new(e) }

      results
    end
  end
end
