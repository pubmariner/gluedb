require File.join(Rails.root, "lib/mongoid_migration_task")
require 'nokogiri'
class FederalTransmissionReport < MongoidMigrationTask  
  def migrate
    batch_file = Nokogiri::XML(File.read("H41_fr/manifest.xml"))
    batch_id = batch_file.xpath('//ns3:BatchID').text
    Dir['H41_fr/EOY_Request*'].each do |file_name|
      content_file_number = file_name.scan(/\d+/)[1]
      file = File.read(file_name) 
      doc = Nokogiri::XML(file)
      doc.xpath('//air5.0:Form1095AUpstreamDetail').each do |node|
        
        record_sequence_number = node.xpath('./air5.0:RecordSequenceNum').text
        federal_policy_id = node.xpath('./air5.0:Policy/air5.0:MarketPlacePolicyNum').text
        
        indicator =
          if node.xpath('./air5.0:VoidInd').text == "0" && node.xpath('./irs:CorrectedInd').text == "false"
            "ORIGINAL"
          elsif node.xpath('./air5.0:VoidInd').text == "1" && node.xpath('./irs:CorrectedInd').text == "false"
            "VOIDED"
          elsif node.xpath('./air5.0:VoidInd').text == "0" && node.xpath('./irs:CorrectedInd').text == "true"
            "CORRECTED"
          end        
        if record_sequence_number.present? && federal_policy_id.present? && content_file_number.present? && batch_id.present?
          policy = Policy.find(federal_policy)
          if policy.present?
            policy.federal_transmissions.create(
                record_sequence_number: record_sequence_number,
                federal_policy_id: federal_policy_id,
                content_file: content_file_number,
                report_type: indicator,
                batch_id: batch_id
            )
          end
          puts "New fedral transmission record created for policy_id:#{federal_policy_id}" unless Rails.env.test?
        end
      end
    end
  end
end