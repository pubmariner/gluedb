module FederalReports
  class ReportEligiblityDetermination
  #This class calls all of the ReportingEligibilityUpdated documents and determines which type of federal report transmission is required for the 
  #associated policy
  #please see 33567
  
    def self.determine_report_transmission_type
      ::PolicyEvents::ReportingEligibilityUpdated.events_for_processing do |record|
        policy = Policy.find(record.policy_id)
        if policy.present? 
          if policy.aasm_state.in?(["canceled", "carrier_canceled"])
            ::FederalReports::ReportProcessor.upload_canceled_reports_for(policy)
          elsif policy.aasm_state.in?(["terminated", "submitted"])
            ::FederalReports::ReportProcessor.upload_active_reports_for(policy)
          end
        end
      end
    end
  end
end