class Optional

  def initialize(value)
    @value = value
  end

  attr_accessor  :value

  def and_then(&block)
    if value.nil?
      Optional.new(nil)
    else
      block.call(value)
    end
  end

  def method_missing(*args, &block)
    and_then do |value|
      Optional.new(value.public_send(*args, &block))
    end
  end

end
