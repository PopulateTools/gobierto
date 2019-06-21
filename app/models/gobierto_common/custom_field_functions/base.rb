# frozen_string_literal: true

module GobiertoCommon
  module CustomFieldFunctions
    class Base
      attr_accessor :record

      delegate :custom_field, :value, to: :record
      delegate :configuration, to: :custom_field

      def initialize(record)
        @record = record
      end
    end
  end
end
