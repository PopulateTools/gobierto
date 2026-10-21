# frozen_string_literal: true

class BaseForm

  include ActiveModel::Model
  include GobiertoCommon::AttributeLengthValidatable

  protected

  def promote_errors(inner_errors)
    inner_errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end

end
