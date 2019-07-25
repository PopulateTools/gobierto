# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class Numeric < Base
    def value=(value)
      if custom_field
        record.payload = { custom_field.uid => value.to_f }
      end
    end

    def value_string
      raw_value.to_s
    end
  end
end
