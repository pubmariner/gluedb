class EdiQueueSetup
  def initialize
    conn = Bunny.new(ExchangeInfo.amqp_uri)
    conn.start
    @channel = conn.create_channel
  end

  def exchange(e_type, name)
    @ch.send(e_type.to_sym, name, {:durable => true})
  end

  def queue(q)
    @ch.queue(q, :durable => true)
  end

  def run
    ec = ExchangeInformation
    ev_exchange = exchange(:topic, ec.event_exchange)

    edi_q = queue(Listeners::EdiQueueListener.queue_name)
  end
end

EdiQueueSetup.new.run
