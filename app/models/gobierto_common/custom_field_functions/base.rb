# frozen_string_literal: true

module GobiertoCommon
  module CustomFieldFunctions
    class Base
      attr_accessor :record

      delegate :custom_field, :value, to: :record
      delegate :configuration, to: :custom_field

      def initialize(record, options = {})
        @record = versioned_record(record, options[:version])
      end

      private

      def versioned_record(record, version_number = nil)
        return record unless version_number.present? && record.item.respond_to?(:versions) && version_number >= 1 && version_number < record.item.versions.length

        version_index = version_number - record.item.versions.length

        return record unless record.versions[version_index].present? && record.versions[version_index].reify.present?

        record.versions[version_index].reify
      end
    end
  end
end
