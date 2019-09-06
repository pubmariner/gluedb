module Listeners
  class ReportEligibilityUpdatedReducerListener < Amqp::RetryClient
    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.glue.report_eligibility_updated_reducer"
    end

    def resource_event_broadcast(level, event_key, r_code, body = "", other_headers = {})
        event_body = (body.respond_to?(:to_s) ? body.to_s : body.inspect)
        broadcast_event({
          :routing_key => "#{level}.application.glue.report_eligibility_updated_reducer.#{event_key}",
          :headers => other_headers.merge({
            :return_status => r_code.to_s,
            :submitted_timestamp => Time.now
          })
        },event_body)
    end

    def resource_error_broadcast(event_key, r_code, body = "", other_headers = {})
      resource_event_broadcast("error", event_key, r_code, body, other_headers)
    end

    def process_retrieved_resource(delivery_info, policy_id, eg_id, m_headers, event_time)
      resource_event_broadcast("info", "event_stored", "200", m_headers.merge({:policy_id => policy_id, :eg_id => eg_id, :event_time => event_time.to_i.to_s}))

      PolicyReportEligibilityUpdated.store_and_yield_deleted(policy_id, eg_id, event_time) do |destroyed_event|
        resource_event_broadcast("info", "event_reduced", "200", destroyed_event.resource_body, {
          :policy_id => destroyed_event.policy_id,
          :eg_id => destroyed_event.eg_id,
          :event_time => destroyed_event.event_time.to_i.to_s
        })
      end
      channel.ack(delivery_info.delivery_tag, false)
    end

    def request_resource(policy_id, eg_id)
      begin
        di, rprops = request({:headers => {:policy_id => policy_id, :eg_id => eg_id}, :routing_key => "resource.policy.report_eligibility_updated"},"", 30)
        r_headers = (rprops.headers || {}).to_hash.stringify_keys
        r_code = r_headers['return_status'].to_s
        if r_code == "200"
          [r_code]
        else
          [r_code]
        end
      rescue Timeout::Error => e
        ["503"]
      end
    end

    def on_message(delivery_info, properties, body)
      m_headers = (properties.headers || {}).to_hash.stringify_keys
      policy_id = m_headers["policy_id"].to_s
      eg_id = m_headers["eg_id"].to_s

      event_time = get_timestamp(properties)
      if PolicyReportEligibilityUpdated.newest_event?(policy_id, eg_id, event_time)
        r_code = request_resource(policy_id, eg_id)
        case r_code.to_s
        when "200"
          process_retrieved_resource(delivery_info, policy_id, eg_id, m_headers, event_time)
        when "404"
          resource_error_broadcast("resource_not_found", r_code, m_headers, m_headers)
          channel.ack(delivery_info.delivery_tag, false)
        when "503"
          resource_error_broadcast("resource_timeout", r_code, m_headers, m_headers)
          channel.reject(delivery_info.delivery_tag, false)
        else
          resource_error_broadcast("unknown_error", r_code, m_headers)
          channel.ack(delivery_info.delivery_tag, false)
        end
      else
        resource_event_broadcast("info", "event_reduced", "200", m_headers.merge({:policy_id => policy_id, :eg_id => eg_id}))
        channel.ack(delivery_info.delivery_tag, false)
      end
    end

    def get_timestamp(msg_properties)
      message_ts = msg_properties.timestamp
      return Time.now if message_ts.blank?
      return Time.at(message_ts) if message_ts.kind_of?(Fixnum) || message_ts.kind_of?(Integer)
      message_ts 
    end

    def self.create_bindings(chan, q)
      ec = ExchangeInformation
      event_topic_exchange_name = "#{ec.id}.#{ec.environment}.e.topic.events"
      event_topic_exchange_name = "#{ec.hbx_id}.#{ec.environment}.e.topic.events"
      event_topic_exchange = chan.topic(event_topic_exchange_name, {:durable => true})
      q.bind(event_topic_exchange, {:routing_key => "info.events.policy.report_eligibility_updated.#"})
    end

    def self.create_queues(chan)
      q = chan.queue(
        self.queue_name,
        {
          :durable => true,
          :arguments => {
            "x-dead-letter-exchange" => (self.queue_name + "-retry")
          }
        }
      )
      retry_q = chan.queue(
        (self.queue_name + "-retry"),
        {
          :durable => true,
          :arguments => {
            "x-dead-letter-exchange" => (self.queue_name + "-requeue"),
            "x-message-ttl" => 1000
          }
        }
      )
      retry_exchange = chan.fanout(
        (self.queue_name + "-retry")
      )
      requeue_exchange = chan.fanout(
        (self.queue_name + "-requeue")
      )
      retry_q.bind(retry_exchange, {:routing_key => ""})
      q.bind(requeue_exchange, {:routing_key => ""})
      q
    end

    def self.run
      Process.setproctitle("%s - %s" % [self.name , $$])
      conn = AmqpConnectionProvider.start_connection
      chan = conn.create_channel
      q = create_queues(chan)
      create_bindings(chan, q)
      chan.prefetch(1)
      self.new(chan, q).subscribe(:block => true, :manual_ack => true, :ack => true)
      conn.close
    end
  end
end
