# frozen_string_literal: true

class BaseForm

  include ActiveModel::Model
  include GobiertoCommon::AttributeLengthValidatable

  protected

  def promote_errors(errors_hash)
    errors_hash.each do |attribute, message|
      errors.add(attribute, message)
    end
  end

end
