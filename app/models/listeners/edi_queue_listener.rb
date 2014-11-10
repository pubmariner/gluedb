module Listeners
  class EdiQueueListener < Amqp::Client
    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.glue.edi_ops"
    end
  end
end
