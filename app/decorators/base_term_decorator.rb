# frozen_string_literal: true

class BaseTermDecorator < BaseDecorator
  class NotImplementedError < StandardError; end

  def initialize(term)
    @object = term
  end

  def self.decorated_values?
    false
  end

  def self.decorated_header_template
    raise NotImplementedError, "Override this with a method returning a template name"
  end

  def self.decorated_values_template
    raise NotImplementedError, "Override this with a method returning a template name"
  end

  def decorated_values
    {}
  end
end
