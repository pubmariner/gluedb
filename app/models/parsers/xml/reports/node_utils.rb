module Parsers::Xml::Reports
  module NodeUtils

    def root_level_elements
      identifiers = @root.elements.inject({}) do |data, node|
        data[node.name.to_sym] = node.text().strip() if node.elements.count.zero?
        data
      end
      @root_elements = OpenStruct.new(identifiers)
    end

    def extract_elements(node)
      independent_element = node.elements.detect{|node| node.elements.count.zero?}
      independent_element.nil? ? extract_collection(node) : extract_properties(node)
    end

    def extract_collection(node)
      node.elements.inject([]) do |data, node|
        data << extract_properties(node)
      end
    end

    def extract_properties(node)
      properties = node.elements.inject({}) do |data, node|
        data[node.name.to_sym] = (node.elements.count.zero? ? node.text().strip() : extract_elements(node))
        data
      end
      OpenStruct.new(properties)
    end

    def parse_date(date)
      Date.parse(date)
    end
  end
end