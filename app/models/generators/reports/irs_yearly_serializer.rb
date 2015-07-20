require 'spreadsheet'
require 'csv'
module Generators::Reports  
  class IrsYearlySerializer

    IRS_XML_PATH = "#{@irs_path}/h41/"
    IRS_PDF_PATH = "#{@irs_path}/irs1095a/"

    def initialize
      @count = 0
      @policy_id = nil
      @hbx_member_id = nil

      @report_names = {}
      @policies = []
      @plans    = nil

      @position = 0
      @pdf_set  = 0
      @irs_set  = 0
      @aptc_versions = []

      @irs_path = "#{Rails.root.to_s}/irs/irs_EOY_#{Time.now.strftime('%m_%d_%Y_%H_%M')}"

      create_directory @irs_path
      create_directory @irs_path + "/h41"
      create_directory @irs_path + "/irs1095a"

      @carriers = Carrier.all.inject({}){|hash, carrier| hash[carrier.id] = carrier.name; hash}
    end

    def generate_notices
      create_new_pdf_folder
      create_new_irs_folder

      CSV.foreach("#{Rails.root}/canceled_policies/canceled_policies.csv") do |row|
        @position += 1
        if @position % 100 == 0
          puts "processed #{@position}"
        end
        next if row[0].strip == 'Policy Number'
        process_policy(row[0].strip)
      end     
    end

    def process_policy_ids(ids)
      create_new_pdf_folder
      create_new_irs_folder
      ids.each do |id|
        process_policy(id)
      end
    end

    def process_policy(policy_id)
      policy = Policy.find(policy_id)
      active_enrollees = policy.enrollees.reject{|en| en.canceled?}

      return if active_enrollees.empty?
      return if rejected_policy?(policy)

      @policy_id = policy.id
      @hbx_member_id = policy.subscriber.person.authority_member.hbx_member_id

      irs_input = Generators::Reports::IrsInputBuilder.new(policy)
      irs_input.carrier_hash = @carriers
      irs_input.process

      notice = irs_input.notice

      notice.active_policies = []
      notice.canceled_policies = []

      create_report_names
      render_xml(notice)
      render_pdf(notice)

      if notice.covered_household.size > 5
        create_report_names
        render_pdf(notice, true)          
      end

      if @count !=0
        if (@count % 250 == 0)
          create_new_pdf_folder
        elsif (@count % 4000 == 0)
          create_new_irs_folder
        end
      end

      notice = nil
      policy = nil
    end

    def process_canceled_pols
      create_new_pdf_folder
      create_new_irs_folder
      CSV.foreach("#{Rails.root}/canceled_policies_to_process1.csv") do |row|

        policy_id = row[1].strip.split(',').first
        policy = Policy.find(policy_id)

        @policy_id = policy.id
        @hbx_member_id = policy.subscriber.person.authority_member.hbx_member_id

        irs_input = Generators::Reports::IrsInputBuilder.new(policy, {void: true})
        irs_input.carrier_hash = @carriers
        irs_input.process

        notice = irs_input.notice
        notice.canceled_policies = convert_to_policy_identifiers(row[1])
        notice.active_policies = convert_to_policy_identifiers(row[2])

        create_report_names
        render_pdf(notice, false, true)

        if @count !=0
          if (@count % 250 == 0)
            create_new_pdf_folder
          elsif (@count % 4000 == 0)
            create_new_irs_folder
          end
        end

        notice = nil
        policy = nil
      end
    end


    def generate_irs_transmission_for_voids(file)
      create_new_irs_folder
      CSV.foreach("#{Rails.root}/#{file}") do |row|
        policy_id = row[0].strip
        record_seq_num = row[1].strip

        policy = Policy.find(policy_id)

        @policy_id = policy.id
        @hbx_member_id = policy.subscriber.person.authority_member.hbx_member_id

        notice = Generators::Reports::IrsInputBuilder.new(policy, void: true).notice
        notice.corrected_record_seq_num = record_seq_num

        create_report_names
        render_xml(notice)

        notice = nil
        policy = nil
      end      
    end

    def create_manifest
      Generators::Reports::Manifest.new.create("#{IRS_XML_PATH + @h41_folder_name}")
    end

    def rejected_policy?(policy)
      edi_transactions = Protocols::X12::TransactionSetEnrollment.where({ "policy_id" => policy.id })
      return true if edi_transactions.count == 1 && edi_transactions.first.aasm_state == 'rejected'
      false
    end

    private

    def create_report_names
      @count += 1
      sequential_number = @count.to_s
      sequential_number = prepend_zeros(sequential_number, 6)
      @report_names = {
        pdf: "#{sequential_number}_HBX_01_#{@hbx_member_id}_#{@policy_id}_IRS1095A",
        xml: "EOY_Request_#{sequential_number}_#{Time.now.utc.iso8601.gsub(/-|:/,'')}"
      }
    end

    def render_xml(notice)
      xml_report = Generators::Reports::IrsYearlyXml.new(notice).serialize.to_xml(:indent => 2)
      File.open("#{IRS_XML_PATH + @h41_folder_name}/#{@report_names[:xml]}.xml", 'w') do |file|
        file.write xml_report
      end
    end

    def render_pdf(notice, multiple = false, void = false)
      pdf_notice = Generators::Reports::IrsYearlyPdfReport.new(notice, multiple, void)
      pdf_notice.render_file("#{IRS_PDF_PATH + @irs1095_folder_name}/#{@report_names[:pdf]}_Corrected.pdf")
    end

    def create_new_pdf_folder
      @pdf_set += 1
      folder_number = prepend_zeros(@pdf_set.to_s, 3)
      @irs1095_folder_name = "DCHBX_IRS1095A_#{Time.now.strftime('%H_%M_%d_%m_%Y')}_#{folder_number}"
      create_directory "#{IRS_PDF_PATH + @irs1095_folder_name}"
    end

    def create_new_irs_folder
      @irs_set += 1
      folder_number = prepend_zeros(@irs_set.to_s, 3)
      @h41_folder_name = "DCHBX_H41_#{Time.now.strftime('%H_%M_%d_%m_%Y')}_#{folder_number}"
      create_directory "#{IRS_XML_PATH + @h41_folder_name}"
    end

    def create_directory(path)
      if Dir.exists?(path)
        FileUtils.rm_rf(path)
      end
      Dir.mkdir path
    end

    def prepend_zeros(number, n)
      (n - number.to_s.size).times { number.prepend('0') }
      number
    end
  end
end