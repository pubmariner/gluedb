require 'nokogiri'

module Generators::Reports  
  class IrsYearlyXmlMerger

    attr_reader :consolidated_doc
    attr_reader :xml_docs

    attr_accessor :irs_yearly_xml_folder


    # DURATION = 12
    # CALENDER_YEAR = 2014


    NS = { 
      "xmlns:air5.0" => "urn:us:gov:treasury:irs:ext:aca:air:5.0",
      "xmlns:irs" => "urn:us:gov:treasury:irs:common",
      "xmlns:batchreq" => "urn:us:gov:treasury:irs:msg:form1095atransmissionupstreammessage",
      "xmlns:batchresp"=> "urn:us:gov:treasury:irs:msg:form1095atransmissionexchrespmessage",
      "xmlns:reqack"=> "urn:us:gov:treasury:irs:msg:form1095atransmissionexchackngmessage",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance"
    }

    def initialize(dir, sequential_number)
      @dir = dir
      timestamp = Time.now.utc.iso8601.gsub(/-|:/,'').match(/(.*)Z/)[1] + "000Z"
      output_file_name = "EOY_Request_#{sequential_number}_#{timestamp}.xml"
      @data_file_path = File.join(@dir,'..', 'transmission', output_file_name)
      @xml_docs = []
      @doc_count = nil
      @consolidated_doc = nil

      # puts "****------------------------"
      # puts @irs_monthly_folder.to_s.inspect
    end

    def process
      @xml_validator = XmlValidator.new
      @xml_validator.folder_path = @irs_yearly_xml_folder.to_s

      read
      merge
      write
      # reset_variables
    end

    # def reset_variables
    #   @xml_docs = []
    #   @doc_count = nil
    #   @consolidated_doc = nil
    # end

    def read
      puts "============"
      puts @dir.inspect
      Dir.glob(@dir+'/*.xml').each do |file_path|
        @xml_docs << Nokogiri::XML(File.open(file_path))
      end
      @doc_count = @xml_docs.count
      @xml_docs
    end

    def merge
      return if @xml_docs.empty?
      if @consolidated_doc == nil
        xml_doc = @xml_docs[0]
        xml_doc = chop_special_characters(xml_doc)
        @consolidated_doc = xml_doc
      end

      @xml_docs.shift

      @consolidated_doc.xpath('//batchreq:Form1095ATransmissionUpstream', NS).each do |node|
        @xml_docs.each do |xml_doc|
          # xml_doc.remove_namespaces!
          new_node = xml_doc.xpath('//air5.0:Form1095AUpstreamDetail').first
          new_node = chop_special_characters(new_node)
          node.add_child(new_node.to_xml(:indent => 2) + "\n")
        end
      end

      @consolidated_doc
    end

    def validate
      @xml_validator.validate(@data_file_path)
      cross_verify_elements
    end

    def cross_verify_elements
      xml_doc = Nokogiri::XML(File.open(@data_file_path))

      element_count = xml_doc.xpath('//air5.0:Form1095AUpstreamDetail', NS).count
      if element_count == @doc_count
        puts "Element count looks OK!!"
      else
        puts "ERROR: Processed #{@doc_count} files...but got #{element_count} elements"
      end
    end

    def write
      File.open(@data_file_path, 'w+') do |file| 
        file.write(@consolidated_doc.to_xml) 
      end
    end


    def self.validate_individuals(dir)
      Dir.glob(dir+'/*.xml').each do |file_path|
        puts file_path.inspect
        @xml_validator.validate(file_path)
      end
    end

    def chop_special_characters(node)

      node.xpath("//irs:SSN", NS).each do |ssn_node|
        update_ssn = Maybe.new(ssn_node.content).strip.gsub("-","").value
        ssn_node.content = update_ssn
      end
      
      ["PersonFirstName", "PersonMiddleName", "PersonLastName", "AddressLine1Txt", "AddressLine2Txt", "CityNm"].each do |ele|
        node.xpath("//irs:#{ele}", NS).each do |xml_tag|
          if xml_tag.content.match(/(\-{1,2}|\'|\#|\"|\&|\<|\>|\.|\,|\s{2})/)
            puts xml_tag.content.inspect
            xml_tag.content = xml_tag.content.gsub(/(\-{1,2}|\'|\#|\"|\&|\<|\>|\.|\,|\s{2})/,"")
          end
        end
      end

      node.xpath("//irs:USZIPCd", NS).each do |xml_tag|
        if  xml_tag.content.match(/(\d{5})-(\d{4})/)
          puts xml_tag.content.inspect
          xml_tag.content = xml_tag.content.match(/(\d{5})-(\d{4})/)[1]
        end
      end

      # node.xpath("//air5.0:RecordSequenceNum", XMLNS).each do |number|
      #   integer_val = Maybe.new(number.content).strip.value.to_i
      #   number.content = integer_val
      # end

      node
    end
  end
end