# frozen_string_literal: true

require 'test_helper'

class User::EditPasswordFormTest < ActiveSupport::TestCase
  def valid_user_edit_password_form
    @valid_user_edit_password_form ||= User::EditPasswordForm.new(
      user_id: user.id,
      password: 'wadus',
      password_confirmation: 'wadus'
    )
  end

  def user
    @user ||= users(:reed)
  end

  def test_validation
    assert valid_user_edit_password_form.valid?
  end

  def test_save
    assert valid_user_edit_password_form.save
  end
end
