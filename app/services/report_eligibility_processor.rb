class ReportEligiblityProcessor
#This class calls all of the ReportingEligibilityUpdated documents, generates the correct 1095As and H41s for them, and publishes them to s3 and sFTP
#please see 33567

  def self.run
    ::PolicyEvents::ReportingEligibilityUpdated.events_for_processing.each do |record|
      policy = Policy.find(record.policy_id)
      if policy.present? 
        if policy.aasm_state.in?(["canceled", "carrier_canceled"])
          void_params = get_doc_params(policy, "void") 
          transmit(void_params) if policy.federal_transmissions.present?# send VOID if current policy is canceled and there are federal transmissions present
        elsif policy.aasm_state.in?(["terminated", "submitted"])
          corrected_params = get_doc_params(policy, "corrected")
          original_params = get_doc_params(policy, "original")
          policy.federal_transmissions.present? ? transmit(corrected_params) : transmit(original_params) #send CORRECTED 1095 if a transmission is present on a submitted/termed policy, send ORGINIAL if there isn't a transmission present
        end
      end
    end
  end

  def self.get_doc_params(policy, type)
    {
      policy_id: policy.id,
      type: type,
      void_cancelled_policy_ids: get_void_cancelled_policy_ids(policy),
      void_active_policy_ids: get_void_active_policy_ids(policy),
      npt: policy.term_for_np
    } 
  end

  def self.get_void_cancelled_policy_ids(policy)
    policy.subscriber.policies.select do |policy|
      base_conditional(policy) && policy.aasm_state == 'canceled'
    end.map(&:id)
  end

  def self.get_void_active_policy_ids(policy)
    policy.subscriber.policies.select do |policy|
      base_conditional(policy) && policy.aasm_state.in?(['submitted','terminated'])
    end.map(&:id)
  end

  def self.base_conditional(policy)
    policy.plan.year == Date.today.prev_year.year &&
    policy.market == "individual" &&
    policy.plan.coverage_type == "health"
  end

  def self.upload_to_s3(file, bucket_name)
    #if file is a zip file it is an h41
    if File.extname(file) == ".zip" 
      Aws::S3Storage.save(file, bucket_name, File.basename(file_name), "h41")
    else 
      Aws::S3Storage.save(file, bucket_name, File.basename(file_name))
    end
  end

  def self.publish_to_sftp(file, bucket_name)
    Aws::S3Storage.publish_to_sftp(file, bucket_name, File.basename(file_name))
  end

  def self.delete_tax_docs
    File.delete(@pfd_file) if @pfd_file
    File.delete(@xml_file) if @xml_file
  end 

  def self.generate_1095A_pdf(params)
    params[:type] = 'new' if params[:type] == 'original'
    @pfd_file = Generators::Reports::IrsYearlySerializer.new(params).generate_notice
  end
  
  def self.generate_h41_xml(params)
    @xml_file = Generators::Reports::IrsYearlySerializer.new(params).generate_h41
  end
  
  
  def self.persist_new_doc
    federal_report = Generators::Reports::Importers::FederalReportIngester.new
    federal_report.federal_report_ingester
  end
  
  def self.transmit(params)
    begin
      if generate_1095A_pdf(params) && generate_h41_xml(params)
         [@pfd_file, @xml_file].each do |file|
            upload_to_s3(file, "tax-documents")
            publish_to_sftp(file, "tax-documents")
         end
         persist_new_doc
         delete_tax_docs
         ::PolicyEvents::ReportingEligibilityUpdated.where(status: "processed").delete_all
      else
        raise("File upload failed")
      end
      rescue Exception => e
        puts e.to_s.inspect
    end
  end

end