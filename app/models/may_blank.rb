class MayBlank
  attr_reader :value  

  def initialize(obj)
    @value = obj
  end

  def fmap(the_proc)
    @value.blank? ? nil : Maybe.new(the_proc.call(@value))
  end

  def method_missing(m, *args, &block)
    target = @value
    self.class.new(target.blank? ? nil : target.__send__(m, *args, &block))
  end

end
