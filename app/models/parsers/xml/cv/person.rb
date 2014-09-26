module Parsers::Xml::Cv
  class Person
    def initialize(parser)
      @parser = parser
    end

    def uri
      @parser.at_xpath('./ns1:id', NAMESPACES).text
    end

    def id
      uri.split('/').last
    end
  end
end
