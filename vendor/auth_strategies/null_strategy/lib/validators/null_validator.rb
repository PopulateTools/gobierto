# frozen_string_literal: true

class NullValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add :data, :invalid
  end
end
