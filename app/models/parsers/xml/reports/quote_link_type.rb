module Parsers::Xml::Reports
  class QuoteLinkType

    def initialize(quote)
      @quote = quote
    end

    def coverage_type
      @quote.at_xpath("n1:coverage_type").text.split("#")[1]
    end

    def rate
      node = @quote.at_xpath("n1:rates/n1:rate/n1:rate")
      node.nil? ? nil : node.text
    end

    def qhp_id
      @quote.at_xpath("n1:qhp_id").text.split("-")[0]
    end
  end
end