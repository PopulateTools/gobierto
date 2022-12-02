# frozen_string_literal: true

module GobiertoData
  module HasCustomTypes
    extend ActiveSupport::Concern

    CUSTOM_TYPES = {
      decimal: :numeric,
      int: :integer,
      char: :text
    }.freeze

    def map_type(type)
      CUSTOM_TYPES.has_key?(type) ? CUSTOM_TYPES[type] : type
    end
  end
end
