# frozen_string_literal: true

module GobiertoCommon
  module CustomFieldValidators
    class Base
      attr_accessor :custom_field_form

      def initialize(custom_field_form)
        @custom_field_form = custom_field_form
      end

      def valid?
        true
      end
    end
  end
end
