module Parsers::Xml::Cv
  module NodeUtils
    def first_text(xpath)
      node = @parser.at_xpath(xpath, NAMESPACES)
      node.nil? ? nil : node.text.strip
    end

    def first_date(xpath)
      text = first_text(xpath)
      return nil if text.blank?
      Date.parse(text).try(:strftime,"%Y%m%d")
    end
  end
end
