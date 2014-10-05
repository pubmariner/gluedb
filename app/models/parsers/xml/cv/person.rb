module Parsers::Xml::Cv
  class Person
    def initialize(parser)
      @parser = parser
    end

    def first_text(xpath)
      node = @parser.at_xpath(xpath, NAMESPACES)
      node.nil? ? nil : node.text
    end

    def name_first
      data = first_text("./ns1:name/ns1:name_first")
      return data unless data.blank?
      full_name = first_text("./ns1:name/ns1:name_full")
      full_name.blank? ? nil : full_name.strip.split(/\s+/).first
    end

    def name_last
      first_text("./ns1:name/ns1:name_last")
    end

    def name_middle
      first_text("./ns1:name/ns1:name_middle")
    end

    def to_request
      {
        :name_first => name_first,
        :name_last => name_last,
        :name_middle => name_middle
      }
    end

  end
end
