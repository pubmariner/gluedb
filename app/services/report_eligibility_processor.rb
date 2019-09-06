class ReportEligiblityProcessor 

  def trigger_1095_creation
    PolicyReportEligibilityUpdated.all.map(&:eg_id).each do |eg_id|
      policy = Policy.where(eg_id: eg_id).first
      if policy.present? 
        if policy.aasm_state.in?(["canceled", "carrier_canceled"])
          void_params = get_doc_params(policy, "void") 
          generate_1095A_pdf(void_params) if policy.federal_transmissions.present?# send VOID if current policy is canceled and there are federal transmissions present
        elsif policy.aasm_state.in?(["terminated", "submitted"])
          corrected_params = get_doc_params(policy, "corrected")
          original_params = get_doc_params(policy, "original")
          policy.federal_transmissions.present? ? generate_1095A_pdf(corrected_params) : generate_1095A_pdf(original_params) #send CORRECTED 1095 if a transmission is present on a submitted/termed policy, send ORGINIAL if there isn't a transmission present
        end
      end
    end
  end

  def get_doc_params(policy, type)
    {
      policy_id: policy.id,
      type: type,
      void_cancelled_policy_ids: get_void_cancelled_policy_ids(policy),
      void_active_policy_ids: get_void_active_policy_ids(policy),
      npt: policy.term_for_np
    } 
  end

  def get_void_cancelled_policy_ids(policy)
    policy.subscriber.policies.select do |policy|
      base_conditional(policy) && policy.aasm_state == 'canceled'
    end.map(&:id)
  end

  def get_void_active_policy_ids(policy)
    policy.subscriber.policies.select do |policy|
      base_conditional(policy) && policy.aasm_state.in?(['submitted','terminated'])
    end.map(&:id)
  end

  def base_conditional(policy)
    policy.plan.year == Date.today.prev_year.year &&
    policy.market == "individual" &&
    policy.plan.coverage_type == "health"
  end

  def upload_to_s3(file_name, bucket_name)
    Aws::S3Storage.save(file_name, bucket_name, File.basename(file_name))
  end

  def delete_1095A_pdf(file_name)
    File.delete(file_name)
  end

  def generate_1095A_pdf(params)
    params[:type] = 'new' if params[:type] == 'original'
    @file_name = Generators::Reports::IrsYearlySerializer.new(params).generate_notice
    begin
      if upload_to_s3(@file_name, "tax-documents")
         persist_new_doc
         delete_1095A_pdf(@file_name)
         PolicyReportEligibilityUpdated.delete_all
      else
        raise("File upload failed")
      end
      rescue Exception => e
         e 
    end
  end

  def persist_new_doc
    federal_report = Generators::Reports::Importers::FederalReportIngester.new
    federal_report.federal_report_ingester
  end

end