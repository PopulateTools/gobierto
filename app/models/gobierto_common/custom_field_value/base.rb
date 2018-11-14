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
        return unless custom_field && payload.present?

        raw_value
      end

      def searchable_value
        value
      end

      def raw_value
        @raw_value ||= if custom_field && payload.present?
                         payload[custom_field.uid]
                       end
      end

      def value=(value)
        if custom_field
          record.payload = { custom_field.uid => value }
        end
      end
    end

  end
end
