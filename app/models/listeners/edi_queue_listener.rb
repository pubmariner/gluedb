module Listeners
  class EdiQueueListener < Amqp::Client
    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.glue.edi_ops"
    end

    def on_message(delivery_info, properties, payload)
      # Don't uncomment this yet.
      # channel.acknowledge(delivery_info.delivery_tag, false) 
    end

    def self.run
      conn = Bunny.new(ExchangeInformation.amqp_uri)
      conn.start
      chan = conn.create_channel
      chan.prefetch(1)
      q = chan.queue(self.queue_name, :durable => true)
      self.new(chan, q).subscribe(:block => true, :manual_ack => true)
    end
  end
end
