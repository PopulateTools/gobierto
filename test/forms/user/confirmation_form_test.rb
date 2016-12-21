require "test_helper"

class User::ConfirmationFormTest < ActiveSupport::TestCase
  def valid_user_confirmation_form
    @valid_user_confirmation_form ||= User::ConfirmationForm.new(
      confirmation_token: unconfirmed_user.confirmation_token,
      name: unconfirmed_user.name,
      password: "wadus",
      password_confirmation: "wadus",
      year_of_birth: unconfirmed_user.year_of_birth,
      gender: unconfirmed_user.gender
    )
  end

  def invalid_user_confirmation_form
    @invalid_user_confirmation_form ||= User::ConfirmationForm.new(
      confirmation_token: nil,
      name: nil,
      password: nil,
      password_confirmation: nil,
      year_of_birth: nil,
      gender: nil
    )
  end

  def unconfirmed_user
    @unconfirmed_user ||= users(:reed)
  end

  def test_validation
    assert valid_user_confirmation_form.valid?
  end

  def test_save
    assert valid_user_confirmation_form.save
  end

  def test_error_messages_with_invalid_attributes
    invalid_user_confirmation_form.save

    assert_equal 1, invalid_user_confirmation_form.errors.messages[:user].size
    assert_equal 1, invalid_user_confirmation_form.errors.messages[:name].size
    assert_equal 1, invalid_user_confirmation_form.errors.messages[:password].size
    assert_equal 1, invalid_user_confirmation_form.errors.messages[:year_of_birth].size
    assert_equal 1, invalid_user_confirmation_form.errors.messages[:gender].size
  end

  def test_user_confirmation
    refute unconfirmed_user.confirmed?

    valid_user_confirmation_form.save
    assert unconfirmed_user.reload.confirmed?
  end

  def test_user_notifications_set_up
    assert unconfirmed_user.disabled_notifications?

    valid_user_confirmation_form.save
    assert unconfirmed_user.reload.immediate_notifications?
  end

  def test_welcome_email_delivery
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      valid_user_confirmation_form.save
    end
  end
end
