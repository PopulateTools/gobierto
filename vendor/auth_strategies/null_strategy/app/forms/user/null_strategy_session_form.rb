# frozen_string_literal: true

class User::NullStrategySessionForm < User::CustomSessionForm

  attr_accessor(
    :name,
    :email,
    :password
  )

  validates_with NullValidator

  def save
    false
  end

  def authentication_data_invalid?
    !valid? && errors.include?(:data)
  end

end
