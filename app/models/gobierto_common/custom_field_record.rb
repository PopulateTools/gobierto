# frozen_string_literal: true

module GobiertoCommon
  class CustomFieldRecord < ApplicationRecord

    VALUE_PROCESSORS = {
      string: CustomFieldValue::Text,
      localized_string: CustomFieldValue::LocalizedText,
      paragraph: CustomFieldValue::MarkdownText,
      localized_paragraph: CustomFieldValue::LocalizedMarkdownText,
      single_option: CustomFieldValue::SingleOption,
      multiple_options: CustomFieldValue::MultipleOptions,
      color: CustomFieldValue::Color,
      image: CustomFieldValue::Image,
      vocabulary_options: CustomFieldValue::VocabularyOptions,
      plugin: CustomFieldValue::Plugin,
      numeric: CustomFieldValue::Numeric,
      default: CustomFieldValue::Base
    }.freeze

    class TypeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        unless value.class.name == record.custom_field&.class_name
          record.errors.add(attribute, :wrong_item_class)
        end
      end
    end

    attr_accessor :item_has_versions, :callback_update

    belongs_to :item, polymorphic: true
    belongs_to :custom_field

    validates :custom_field, presence: true
    validates :item, presence: true, type: true

    scope :searchable, -> { joins(:custom_field).where(custom_fields: { field_type: CustomField.searchable_fields }) }
    scope :for_item, ->(item) { where(item: item) }
    scope :with_field_type, ->(field_type) { joins(:custom_field).where(custom_fields: { field_type: field_type }) }
    scope :sorted, -> { joins(:custom_field).order(position: :asc) }

    has_paper_trail if: ->(this) { this.item_has_versions }

    delegate :value, :value_string, :raw_value, :value=, :filter_value, :searchable_value, to: :value_processor

    after_save :check_plugin_callbacks, :touch_item

    def value_processor
      key = VALUE_PROCESSORS.has_key?(custom_field&.field_type&.to_sym) ? custom_field.field_type.to_sym : :default
      VALUE_PROCESSORS[key].new(self)
    end

    def functions(version: nil)
      return unless custom_field.plugin?

      unless GobiertoCommon::CustomFieldFunctions.const_defined?(custom_field.configuration.plugin_type.classify)
        begin
          GobiertoCommon::CustomFieldFunctions.const_get(custom_field.configuration.plugin_type.classify)
        rescue NameError
          return
        end
      end

      GobiertoCommon::CustomFieldFunctions.const_get(custom_field.configuration.plugin_type.classify).new(self, version: version)
    end

    def item_class
      custom_field&.class_name&.constantize
    end

    private

    def touch_item
      return if item_has_versions || callback_update

      item.touch
    end

    def check_plugin_callbacks
      plugin_types_with_callbacks = GobiertoCommon::CustomFieldPlugin.with_callbacks.map(&:type)

      return if plugin_types_with_callbacks.blank?

      custom_fields_with_callbacks = GobiertoCommon::CustomField.plugin
                                                                .where(instance: custom_field.instance)
                                                                .where("options -> 'configuration' ->> 'plugin_type' in (:types)", types: plugin_types_with_callbacks)

      custom_fields_with_callbacks.each do |custom_field_with_callback|
        next unless custom_field_with_callback.refers_to?(custom_field)

        GobiertoCommon::CustomFieldRecord.find_or_initialize_by(item: item, custom_field: custom_field_with_callback).tap do |record|
          plugin_type = custom_field_with_callback.configuration.plugin_type
          GobiertoCommon::CustomFieldPlugin.find(plugin_type).callbacks.each do |callback|
            next unless record.functions.respond_to? callback

            record.functions.send(callback)
          end
        end
      end
    end
  end
end
