module Parsers::Xml::Cv
  class Individual
    def initialize(parser)
      @parser = parser
    end

    def incomes
      results = []

      elements = @parser.xpath('./ns1:financial/ns1:incomes/ns1:income', NAMESPACES)
      elements.each { |i| results << Income.new(i) }

      results
    end

    def person
      Person.new(@parser.at_xpath('./ns1:financial/ns1:person', NAMESPACES))
    end
  end
end
