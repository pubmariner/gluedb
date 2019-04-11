require File.join(Rails.root, "lib/mongoid_migration_task")
require 'nokogiri'

class FederalTransmissionReport < MongoidMigrationTask  
  def migrate
    Dir['H41_fr/EOY_Request*'].each do |file_name|
      content_file_number = file_name.scan(/\d+/)[1]
      file = File.read(file_name) 
      doc = Nokogiri::XML(file)
      doc.xpath('//air5.0:Form1095AUpstreamDetail').each do |node|
        
        record_sequence_number = node.xpath('./air5.0:RecordSequenceNum').each do |seq_node|
          seq_node.text
        end

        def indicator
          if node.xpath('./air5.0:VoidInd').first.text == "0" && node.xpath('./irs:CorrectedInd')first.text == "false"
            puts "ORIGINAL"
          elsif node.xpath('./air5.0:VoidInd').first.text == "1" && node.xpath('./irs:CorrectedInd')first.text == "false"
            puts "VOIDED"
          elsif node.xpath('./air5.0:VoidInd').first.text == "0" && node.xpath('./irs:CorrectedInd')first.text == "true"
            puts "CORRECTED"
          end
        end

        federal_policy = node.xpath('./air5.0:Policy/air5.0:MarketPlacePolicyNum').each do |policy_node|
          policy_node.text
        end

        if record_sequence_number.present? && federal_policy.present?
            FederalTransmission.create(
                :record_sequence_number => record_sequence_number,
                :federal_policy_id => federal_policy,
                :content_file => content_file_number,
                :report_type => indicator
            )
        end
      end
    end
  end
end

      