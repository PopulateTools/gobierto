# frozen_string_literal: true

class BaseDecorator
  attr_reader :object

  # Let's pretend we're someone else in Rails
  #
  delegate :is_a?, :kind_of?, :respond_to?, :to_model, :to_param, :class, to: :object

  def method_missing(*args, &block)
    object.send(*args, &block)
  end
end
