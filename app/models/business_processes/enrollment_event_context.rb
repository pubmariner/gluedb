module BusinessProcesses
  class EnrollmentEventContext
    attr_accessor :enrollment_event_errors
    attr_accessor :business_process_history
    attr_accessor :amqp_connection
    attr_accessor :event_list
    attr_accessor :terminations
    attr_accessor :cancellations
    attr_accessor :errors
    attr_accessor :event_message

    delegate :event_xml, :to => :event_message, :allow_nil => true

    def initialize
      @errors = ::BusinessProcesses::EnrollmentEventErrors.new
      @terminations = []
      @cancellations = []
    end

    def hbx_enrollment_id
      if !event_message.nil?
        event_message.hbx_enrollment_id
      elsif !event_list.nil?
        event_list.map(&:hbx_enrollment_id).to_json
      end
    end

    private

    def initialize_clone(other)
      @errors = other.errors.clone
      if other.business_process_history.present?
        @business_process_history = other.business_process_history.clone
      end
      if other.amqp_connection.present?
        @amqp_connection = other.amqp_connection
      end
      if other.event_message.present?
        @event_message = other.event_message.clone
      end
      if other.terminations.any?
        @terminations = other.terminations.clone
      end
      if other.cancellations.any?
        @terminations = other.cancellations.clone
      end
    end
  end
end
