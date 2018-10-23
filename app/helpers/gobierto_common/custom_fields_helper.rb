# frozen_string_literal: true

module GobiertoCommon
  module CustomFieldsHelper
    def custom_field_by_uid(item, uid)
      record = GobiertoCommon::CustomFieldRecord.find_by(item: item, custom_field: get_custom_field_by_uid(item, uid))

      return unless record.present?

      if record.custom_field.long_text?
        markdown(record.value)
      else
        record.value
      end
    end

    def custom_field_name_by_uid(item, uid)
      get_custom_field_by_uid(item, uid)&.name
    end

    protected

    def get_custom_field_by_uid(item, uid)
      GobiertoCommon::CustomField.find_by(uid: uid, class_name: item.class.name)
    end
  end
end
