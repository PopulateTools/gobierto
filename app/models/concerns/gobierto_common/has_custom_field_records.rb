# frozen_string_literal: true

module GobiertoCommon
  module HasCustomFieldRecords
    extend ActiveSupport::Concern

    included do
      if has_custom_fields_enabled?
        has_many :custom_field_records, as: :item, class_name: "GobiertoCommon::CustomFieldRecord", dependent: :destroy

        def custom_field_record_with_uid(uid)
          custom_field_records.joins(:custom_field).find_by(custom_fields: { uid: uid })
        end
      end
    end

    module ClassMethods
      def has_custom_fields_enabled?
        module_class.try(:classes_with_custom_fields)&.include? self
      end

      def module_class
        @module_class ||= recursive_deconstantize(name).constantize
      end

      def recursive_deconstantize(name)
        deconstantized_name = name.deconstantize
        return name if deconstantized_name.blank?

        recursive_deconstantize(deconstantized_name)
      end
    end
  end
end
