class ChannelProvider
  def self.with_channel
    bunny = Bunny.new
    bunny.start
    chan = bunny.create_channel
    yield chan
    bunny.stop
  end
end
