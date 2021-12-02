# frozen_string_literal: true

module GobiertoIndicators
  def self.table_name_prefix
    "gi_"
  end

  def self.root_path(_)
    Rails.application.routes.url_helpers.gobierto_indicators_indicators_ita_path
  end

  class << self
    alias_method :cache_base_key, :table_name_prefix
  end
end
