module Parsers::Xml::Cv
  module NodeUtils
    def first_text(xpath)
      Maybe.new(@parser).at_xpath(xpath, NAMESPACES).text.strip.value
    end

    def first_date_as_date(xpath)
      text = first_text(xpath)
      return nil if text.blank?
      return nil if text.strip.starts_with?("0001")
      Date.parse(text)
    end

    def first_date(xpath)
      text = first_text(xpath)
      return nil if text.blank?
      return nil if text.strip.starts_with?("0001")
      Date.parse(text)
    end
  end
end
