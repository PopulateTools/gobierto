# frozen_string_literal: true

module GobiertoCommon::CustomFieldValue
  class Numeric < Base
    def value=(value)
      if custom_field
        record.payload = { custom_field.uid => value.blank? ? nil : self.class.parse_float(value) }
      end
    end

    def value_string
      raw_value.to_s
    end

    def self.parse_float(value)
      return value.to_f if value.is_a? ::Numeric

      value.to_s.tr(",", value.count(".") > 0 || value.count(",") > 1 ? "" : ".").to_f
    end
  end
end
