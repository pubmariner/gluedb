class ExchangeInformation

  class MissingKeyError < StandardError
    def initialize(key)
      super("Missing required key: #{key}") 
    end
  end

  include Singleton

  REQUIRED_KEYS = [
    'receiver_id', 'invalid_argument_queue', 'processing_failure_queue'
    ]

  # TODO: I have a feeling we may be using this pattern
  #       A LOT.  Look into extracting it if we repeat.
  def initialize
    @config = YAML.load_file(Rails.root.join('config', 'exchange.yml'))
    ensure_configuration_values(@config)
  end

  def ensure_configuration_values(conf)
    REQUIRED_KEYS.each do |k|
      if @config[k].blank?
        raise MissingKeyError.new(k)
      end
    end
  end

  def receiver_id
    @config['receiver_id']
  end

  def invalid_argument_queue
    @config['invalid_argument_queue']
  end

  def processing_failure_queue
    @config['processing_failure_queue']
  end

  def self.receiver_id
    self.instance.receiver_id
  end

  def self.invalid_argument_queue
    self.instance.invalid_argument_queue
  end

  def self.processing_failure_queue
    self.instance.processing_failure_queue
  end
end
