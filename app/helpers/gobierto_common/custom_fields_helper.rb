# frozen_string_literal: true

module GobiertoCommon
  module CustomFieldsHelper
    def custom_field_by_uid(item, uid)
      GobiertoCommon::CustomFieldRecord.find_by(item: item, custom_field: GobiertoCommon::CustomField.find_by(uid: uid))&.value
    end
  end
end
