module FederalReports
  class ReportProcessor
    #this class builds the appropriate parameters to be sent to the report uploader

    def self.transmit_cancelled_reports_for(policy)
      return if policy.federal_transmissions.empty?
      void_params = get_doc_params(policy, "void") 
      ::FederalReports::ReportUploader.upload(void_params) # send VOID if current policy is canceled and there are federal transmissions present 
    end

    def self.transmit_active_reports_for(policy)
      corrected_params = get_doc_params(policy, "corrected")
      original_params = get_doc_params(policy, "original")
      policy.federal_transmissions.present? ? transmit(corrected_params) : transmit(original_params) #send CORRECTED 1095 if a transmission is present on a submitted/termed policy, send ORGINIAL if there isn't a transmission present
    end


    def self.get_doc_params(policy, type)
      {
        policy_id: policy.id,
        type: type,
        void_cancelled_policy_ids: get_void_cancelled_policy_ids_of_subscriber(policy),
        void_active_policy_ids: get_void_active_policy_ids_of_subscriber(policy),
        npt: policy.term_for_np
      } 
    end

    def self.base_conditional(policy)   
      if policy.is_shop? || policy.coverage_type.to_s.downcase != "health" || policy.coverage_year.first.year == Time.now.year || policy.coverage_year.first.year < 2018
        false 
      else  
        true
      end
    end

    def self.get_void_cancelled_policy_ids_of_subscriber(policy)
      policy.subscriber.person.policies.select do |policy|
        base_conditional(policy) && policy.aasm_state == 'canceled'
      end.map(&:id)
    end
  
    def self.get_void_active_policy_ids_of_subscriber(policy)
      policy.subscriber.person.policies.select do |policy|
        base_conditional(policy) && policy.aasm_state.in?(['submitted','terminated'])
      end.map(&:id)
    end
  
  end 
end