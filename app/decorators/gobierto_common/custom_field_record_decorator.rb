# frozen_string_literal: true

module GobiertoCommon
  class CustomFieldRecordDecorator < BaseDecorator

    TAG_ATTRIBUTES = {
      string: {
        class_names: "form_item input_text",
        field_tag: :text_field_tag,
        partial: "item",
        tag_attributes: {}
      },
      localized_string: {
        class_names: "form_item input_text",
        field_tag: :text_field_tag,
        partial: "localized_item",
        tag_attributes: {}
      },
      paragraph: {
        class_names: "form_item input_text",
        field_tag: :text_area_tag,
        partial: "item",
        tag_attributes: { data: { wysiwyg: true } }
      },
      localized_paragraph: {
        class_names: "form_item input_text",
        field_tag: :text_area_tag,
        partial: "localized_item",
        tag_attributes: { data: { wysiwyg: true } }
      },
      single_option: {
        class_names: "form_item select_control",
        field_tag: :select_tag,
        partial: "item",
        tag_attributes: {}
      },
      multiple_options: {
        class_names: "form_item select_control",
        field_tag: :select_tag,
        partial: "item",
        tag_attributes: { multiple: true }
      },
      color: {
        class_names: "form_item input_text",
        field_tag: :text_field_tag,
        partial: "color",
        tag_attributes: { data: { behavior: "colorpicker" } }
      },
      image: {
        class_names: "form_item file_field avatar_file_field",
        field_tag: :file_field_tag,
        partial: "image",
        tag_attributes: {}
      },
      vocabulary_options: {
        class_names: ->(record) { record.vocabulary_class_names },
        field_tag: :select_tag,
        partial: "vocabulary",
        tag_attributes: ->(record) { record.vocabulary_type_attributes }
      },
      data_grid: {
        class_names: "form_item file_field avatar_file_field",
        field_tag: :hidden_field_tag,
        partial: "data_grid",
      }
    }.freeze

    attr_accessor :site

    delegate :name, :field_type, :options, :uid, :required?, :has_options?, :has_localized_value?, :has_vocabulary?, to: :custom_field

    def initialize(record)
      @object = record
    end

    def custom_field
      object.custom_field
    end

    def required?
      custom_field.mandatory
    end

    [:class_names, :field_tag, :tag_attributes, :partial].each do |name|
      define_method(name) do
        TAG_ATTRIBUTES[field_type.to_sym][name].is_a?(Proc) ? TAG_ATTRIBUTES[field_type.to_sym][name].call(self) : TAG_ATTRIBUTES[field_type.to_sym][name]
      end
    end

    def input_content
      if has_options?
        if has_vocabulary?
          ApplicationController.helpers.options_for_select(
            VocabularyDecorator.new(custom_field.vocabulary).terms_for_select,
            value.map(&:id)
          )
        else
          ApplicationController.helpers.options_for_select(custom_field.localized_options(I18n.locale), payload.present? && payload[uid])
        end
      else
        has_localized_value? ? raw_value : value
      end
    end

    def vocabulary_type_attributes
      {
        multiple: !vocabulary_single_select?,
        data: { behavior: custom_field.configuration["vocabulary_type"] }
      }
    end

    def vocabulary_class_names
      "form_item select_control #{"p_1" unless vocabulary_single_select?}"
    end

    def vocabulary_single_select?
      return unless custom_field.configuration

      custom_field.configuration["vocabulary_type"] == "single_select"
    end

    def custom_field_id
      custom_field.id
    end

    def custom_fields
      site.custom_field_records.where(item: object)
    end
  end
end
