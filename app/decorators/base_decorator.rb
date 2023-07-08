class BaseDecorator
  attr_reader :object

  # Let's pretend we're someone else in Rails
  #
  delegate :is_a?, :kind_of?, :respond_to?, :to_model, :to_param, :class, to: :object

  def method_missing(method_name, *args, &block)
    object.send(method_name, *args, &block)
  end
end
