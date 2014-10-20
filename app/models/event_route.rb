class EventRoute
  include Mongoid::Document
  
  field :event_uri, type: String
  field :exchange_name, type: String
  field :exchange_kind, type: String
  field :routing_key, type: String

  index({:event_uri => 1})

  def resolve_exchange(channel)
    if "default" == self.exchange_kind.to_s.downcase
      return channel.default_exchange
    end
    channel.send(*[self.exchange_kind.to_s, self.exchange_name.to_s])
  end

  def self.from_amqp_uri(uri)
    components = uri.split(/:/)
    self.new(
      :exchange_name => components[2],
      :exchange_kind => components[1],
      :routing_key => components[3]
    )
  end

  def self.for_event_uri(event_uri)
    self.where(:event_uri => event_uri)
  end
end
