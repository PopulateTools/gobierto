# frozen_string_literal: true

class DomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, :not_valid_format if value.present? && value.split('.').length < 2
  end
end
