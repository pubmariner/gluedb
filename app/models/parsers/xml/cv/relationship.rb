module Parsers::Xml::Cv
  class Relationship
    def initialize(parser)
      @parser = parser
    end

    def subject
      @parser.at_xpath('./ns1:subject_individual', NAMESPACES).text
    end

    def relationship_urn
      @parser.at_xpath('./ns1:relationship_uri', NAMESPACES).text
    end

    def relationship
      relationship_urn.split('#').last
    end

    def inverse_relationship_urn
      node = @parser.at_xpath('./ns1:inverse_relationship_uri', NAMESPACES)
      (node.nil?) ? nil : node.text
    end

    def inverse_relationship
      urn = inverse_relationship_urn
      (urn.nil?) ? nil : urn.split('#').last
    end

    def object
      @parser.at_xpath('./ns1:object_individual', NAMESPACES).text
    end
  end
end
