# frozen_string_literal: true

require "test_helper"

class User::ConfirmationFormTest < ActiveSupport::TestCase
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
      custom_records: {
        madrid_custom_user_field_district.name => { "custom_user_field_id" => madrid_custom_user_field_district.id, "value" => madrid_custom_user_field_district.options.keys.first },
        madrid_custom_user_field_association.name => { "custom_user_field_id" => madrid_custom_user_field_association.id, "value" => "Foo" }
      },
      document_number: "00000000A",
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
      document_number: nil,
      site: nil
    )
  end

  def madrid_custom_user_field_district
    @madrid_custom_user_field_district ||= gobierto_common_custom_user_fields(:madrid_custom_user_field_district)
  end

  def madrid_custom_user_field_association
    @madrid_custom_user_field_association ||= gobierto_common_custom_user_fields(:madrid_custom_user_field_association)
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
    assert_equal 1, invalid_user_confirmation_form.errors.messages[:date_of_birth].size
    assert_equal 1, invalid_user_confirmation_form.errors.messages[:gender].size
  end

  def test_user_confirmation_and_verification
    refute unconfirmed_user.confirmed?

    valid_user_confirmation_form.save
    assert unconfirmed_user.reload.confirmed?
  end

  def test_user_users_fails_census_verification_because_was_disabled
    # this is disabled after removal of the old module. Previously, it was used to obtain an additional
    # verification specific to some modules, taking the user.referrer_entity, which points to the module
    # that required these steps. like set to true census_verified?
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
