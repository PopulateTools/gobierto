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
      }
    }.freeze

    attr_accessor :site

    delegate :name, :field_type, :options, :uid, :required?, :has_options?, :has_localized_value?, to: :custom_field

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
        TAG_ATTRIBUTES[field_type.to_sym][name]
      end
    end

    def input_content
      if has_options?
        ApplicationController.helpers.options_for_select(custom_field.localized_options(I18n.locale), payload.present? && payload[uid])
      else
        has_localized_value? ? raw_value : value
      end
    end

    def custom_field_id
      custom_field.id
    end

    def custom_fields
      site.custom_field_records.where(item: object)
    end
  end
end
