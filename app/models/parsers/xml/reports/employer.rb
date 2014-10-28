module Parsers::Xml::Reports
  class Employer

    def initialize(xml_file=nil)
      # parser = File.open(Rails.root.to_s + "/employer.xml")
      parser = Nokogiri::XML(xml_file)
      @root = parser.root
    end

    def ein
      @root.at_xpath("n1:fein").text
    end

    def name
      @root.at_xpath("n1:name").text
    end

    # Address Type checking?
    def addresses
      addresses = []
      @root.xpath("n1:contacts/n1:contact/n1:addresses/n1:address").each do |ele|
        address = {
          address_1: ele.at_xpath('n1:address_1').text,
          city: ele.at_xpath('n1:city').text,
          state: ele.at_xpath('n1:state').text,
          postal_code: ele.at_xpath('n1:postal_code').text
        }
        address.merge({address_2: ele.at_xpath('n1:address_2').text}) if ele.at_xpath('n1:address_2')
        addresses << address
      end
      addresses
    end
  end
end
