module Listeners
  class CarefirstPolicyUpdate
    def initialize(controller, transmission_fact = Protocols::Csv::CsvTransmission, transaction_fact = Protocols::Csv::CsvTransaction, file_fact = FileString)
      @controller = controller
      @transmission_factory = transmission_fact
      @transaction_factory = transaction_fact
      @file_factory = file_fact
      @errors = []
    end

    def invalid_attestation_date(details = {})
      @errors << "Invalid attestation date: #{details[:attestation_date]}"
    end

    def transaction_after_attestation(t_date, a_date)
      @errors << "A transaction occured on #{t_date} after the attestation date of #{a_date}"
    end

    def non_authority_member(s_id)
      @errors << "Member #{s_id} is not the authority member"
    end

    def begin_date_mismatch(details)
      @errors << "Begin date does not match. Provided: #{details[:provided]}, Existing: #{details[:existing]}"
    end

    def policy_not_found(policy_id)
      @errors << "Policy(#{policy_id}) not found."
    end

    def invalid_dates(dates)
      @errors << "Invalid date combination: Begin-#{dates[:begin_date]}, End-#{dates[:end_date]}."
    end

    def policy_status_is_same
      @errors << "Policy status is the same."
    end

    def subscriber_id_mismatch(details)
      @errors << "Subscriber ID does not match. Provided: #{details[:provided]}, Existing: #{details[:existing]}"
    end

    def enrolled_count_mismatch(details)
      @errors << "Enrolled Count does not match. Provided: #{details[:provided]}, Existing: #{details[:existing]}"
    end

    def plan_mismatch(details)
      @errors << "Plan does not match. Provided: #{details[:provided]}, Existing: #{details[:existing]}"
    end

    def enrollee_end_date_is_different
      @errors << "An enrollee's end date doesn't match the subscriber's"
    end

    def invalid_status(details)
      @errors << "Invalid status: #{details[:provided]} must be one of: #{details[:allowed]}"
    end

    def create_transmission(details)
      transmission_keys = [:carrier_id, :file_name, :submitted_by, :batch_id]
      transmission_properties = details.select { |k, _| transmission_keys.include?(k) }
      @transmission_factory.find_or_create_transmission(transmission_properties)
    end

    def create_body(details)
      fs_name = details[:batch_id].to_s + "_" + details[:batch_index].to_s + "_" + details[:file_name].to_s
      @file_factory.new(fs_name, details[:body])
    end

    def fail(details)
      transmission = create_transmission(details)
      @transaction_factory.create_transaction({
        :error_list => @errors,
        :csv_transmission_id => transmission.id,
        :batch_index => details[:batch_index],
        :policy_id => details[:policy_id],
        :body => create_body(details)
      })
      @controller.respond_to_failure(@errors)
    end

    def success(details)
      transmission = create_transmission(details)
      @transaction_factory.create_transaction({
        :error_list => @errors,
        :csv_transmission_id => transmission.id,
        :batch_index => details[:batch_index],
        :policy_id => details[:policy_id],
        :body => create_body(details)
      })
      @controller.respond_to_success
    end
  end

end
