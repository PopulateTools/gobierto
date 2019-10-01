# frozen_string_literal: true

module GobiertoIndicators
  def self.table_name_prefix
    "gi_"
  end

  def self.root_path(_)
    Rails.application.routes.url_helpers.gobierto_indicators_indicators_ita_path
  end
end
