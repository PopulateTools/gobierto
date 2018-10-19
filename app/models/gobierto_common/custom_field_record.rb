# frozen_string_literal: true

module GobiertoCommon
  class CustomFieldRecord < ApplicationRecord

    VALUE_PROCESSORS = {
      string: CustomFieldValue::Text,
      localized_string: CustomFieldValue::LocalizedText,
      paragraph: CustomFieldValue::Text,
      localized_paragraph: CustomFieldValue::LocalizedText,
      single_option: CustomFieldValue::SingleOption,
      multiple_options: CustomFieldValue::MultipleOptions,
      color: CustomFieldValue::Color,
      image: CustomFieldValue::Image,
      default: CustomFieldValue::Base
    }.freeze

    class TypeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        unless value.class.name == record.custom_field&.class_name
          record.errors.add(attribute, :wrong_item_class)
        end
      end
    end

    belongs_to :item, polymorphic: true
    belongs_to :custom_field

    validates :custom_field, presence: true
    validates :item, presence: true, type: true

    delegate :value, :raw_value, :value=, to: :value_processor

    def value_processor
      key = VALUE_PROCESSORS.has_key?(custom_field&.field_type&.to_sym) ? custom_field.field_type.to_sym : :default
      VALUE_PROCESSORS[key].new(self)
    end

    def item_class
      custom_field&.class_name&.constantize
    end
  end
end
