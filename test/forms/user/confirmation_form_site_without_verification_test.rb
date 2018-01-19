# frozen_string_literal: true

require "test_helper"

class User::ConfirmationFormSiteWithoutVerificationTest < ActiveSupport::TestCase
  def valid_user_confirmation_form
    @valid_user_confirmation_form ||= User::ConfirmationForm.new(
      confirmation_token: unconfirmed_user.confirmation_token,
      name: unconfirmed_user.name,
      password: "wadus",
      password_confirmation: "wadus",
      date_of_birth_year: 1992,
      date_of_birth_month: 1,
      date_of_birth_day: 1,
      gender: unconfirmed_user.gender,
      site: unconfirmed_user.site
    )
  end

  def invalid_user_confirmation_form
    @invalid_user_confirmation_form ||= User::ConfirmationForm.new(
      confirmation_token: nil,
      name: nil,
      password: nil,
      password_confirmation: nil,
      date_of_birth_year: nil,
      date_of_birth_month: nil,
      date_of_birth_day: nil,
      gender: nil,
      site: nil
    )
  end

  def unconfirmed_user
    @unconfirmed_user ||= users(:charles)
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
    assert_equal 1, invalid_user_confirmation_form.errors.messages[:date_of_birth].size
    assert_equal 1, invalid_user_confirmation_form.errors.messages[:gender].size
  end

  def test_user_confirmation_and_verification
    refute unconfirmed_user.confirmed?

    valid_user_confirmation_form.save
    assert unconfirmed_user.reload.confirmed?
    refute unconfirmed_user.census_verified?
  end

  def test_false_password_enabled_attribute
    invalid_user_confirmation_form.password_enabled = false

    valid_user_confirmation_form.password_enabled = false
    valid_user_confirmation_form.password = nil
    valid_user_confirmation_form.password_confirmation = nil

    refute invalid_user_confirmation_form.save
    assert_empty invalid_user_confirmation_form.errors.messages[:password]

    assert valid_user_confirmation_form.save
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
