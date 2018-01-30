# frozen_string_literal: true

require 'active_support'

class NullStrategy
  extend ActiveSupport::Autoload

  def self.eager_load!
    super
    require_relative '../app/forms/user/null_strategy_session_form'
  end
end
