# frozen_string_literal: true

module CustomUserFieldsHelper
  def options_for_custom_user_record(custom_record)
    options_for_select(custom_record.custom_user_field.options.map { |k, v| [v[I18n.locale.to_s], k] }, custom_record.payload.present? && custom_record.payload[custom_record.custom_user_field.name])
  end
end
