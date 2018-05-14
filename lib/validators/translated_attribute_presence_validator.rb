# frozen_string_literal: true

class TranslatedAttributePresenceValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    record.errors.add attribute, :blank if value.blank? || !any_value_present?(value)
  end

  private

  def any_value_present?(value)
    value.values.any?(&:present?)
  end

end
