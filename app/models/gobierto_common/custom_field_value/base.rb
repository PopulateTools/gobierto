# frozen_string_literal: true

module GobiertoCommon
  module CustomFieldValue
    class Base
      attr_accessor :record

      delegate :custom_field, :payload, :uid, to: :record

      def initialize(record)
        @record = record
      end

      def value
        return default_value unless custom_field && payload.present?

        raw_value
      end
      alias filter_value value

      def value_string
        value
      end

      def searchable_value
        value_string
      end

      def raw_value
        @raw_value ||= if custom_field && payload.present?
                         payload[custom_field.uid]
                       end
      end
      alias raw_api_value raw_value

      def default_value
        custom_field.configuration.multiple ? [] : nil
      end

      def value=(value)
        if custom_field
          record.payload = { custom_field.uid => value }
        end
      end

      def external_id; end
    end

  end
end
