# frozen_string_literal: true

module GobiertoCore
  class CurrentScope
    thread_mattr_accessor :current_site
  end
end
