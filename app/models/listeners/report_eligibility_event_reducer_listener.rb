#listens for pending batch objects remaining in federal_reporting_eligiblity_updated and sends out corresponding 1095s and H41s
module Listeners
  class ReportEligiblityEventReducerListener < ::Amqp::Client
    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.glue.report_eligibility_event_reducer_listener"
    end

    def on_message(delivery_info, properties, body)
      m_headers = (properties.headers || {}).to_hash.stringify_keys
      ec = ExchangeInformation
      time_boundry = Time.now
      event_time = get_timestamp(m_headers)
      policy =  Policy.find(m_headers['policy_id'])
      if policy.present?
        ReportEligiblityProcessor.new(policy)
      end
    end

    def get_timestamp(msg_properties)
      message_ts = msg_properties['timestamp']
      return Time.now if message_ts.blank?
      return Time.at(message_ts) if message_ts.kind_of?(Fixnum) || message_ts.kind_of?(Integer)
      message_ts 
    end

  end 
end