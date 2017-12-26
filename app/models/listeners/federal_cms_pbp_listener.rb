module Listeners
  class FederalCmsPbpListener < Amqp::Client
    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.glue.federal_cms_pbp_listener"
    end

    def resource_event_broadcast(level, event_key, r_code, body = "", other_headers = {})
        event_body = (body.respond_to?(:to_s) ? body.to_s : body.inspect)
        broadcast_event({
          :routing_key => "#{level}.application.glue.federal_cms_pbp_listener.#{event_key}",
          :headers => other_headers.merge({
            :return_status => r_code.to_s,
            :submitted_timestamp => Time.now
          })
        },event_body)
    end

    def resource_error_broadcast(event_key, r_code, body = "", other_headers = {})
      resource_event_broadcast("error", event_key, r_code, body, other_headers)
    end

    def on_message(delivery_info, properties, body)
      m_headers = (properties.headers || {}).to_hash.stringify_keys

      coverage_year = m_headers["coverage_year"].to_s
      pbp_final = m_headers["pbp_final"].to_s

      r_code, resource_or_body = Generators::Reports::SbmiSerializer.generate_sbmi(self, coverage_year, pbp_final)

      case r_code.to_s
      when "200"
        channel.ack(delivery_info.delivery_tag, false)
      else # r_code: 500
        resource_error_broadcast("report_timeout", r_code)
        channel.reject(delivery_info.delivery_tag, true)
      # else
      #   resource_error_broadcast("unknown_error", r_code, resource_or_body)
      #   channel.ack(delivery_info.delivery_tag, false)
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
      event_topic_exchange_name = "#{ec.hbx_id}.#{ec.environment}.e.topic.events"
      event_topic_exchange = chan.topic(event_topic_exchange_name, {:durable => true})
      q.bind(event_topic_exchange, {:routing_key => "info.events.report.federal_cms_pbp"})
    end

    def self.create_queues(chan)
      q = chan.queue(
        self.queue_name,
        {
          :durable => true,
        }
      )
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