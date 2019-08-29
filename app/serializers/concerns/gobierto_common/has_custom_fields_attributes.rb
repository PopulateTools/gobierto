# frozen_string_literal: true

module GobiertoCommon
  module HasCustomFieldsAttributes

    extend ActiveSupport::Concern

    def attributes(*args)
      data = super

      custom_fields_attributes = current_site.custom_fields.where(class_name: object.class.name).inject({}) do |attrs, custom_field|
        attrs.update(
          custom_field.uid => ::GobiertoCommon::CustomFieldRecord.find_or_initialize_by(
            item: object,
            custom_field: custom_field
          ).value
        )
      end
      data.merge(custom_fields_attributes)
    end

  end
end
