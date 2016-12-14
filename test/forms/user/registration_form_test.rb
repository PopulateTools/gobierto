require "test_helper"

class User::RegistrationFormTest < ActiveSupport::TestCase
  def valid_user_registration_form
    @valid_user_registration_form ||= User::RegistrationForm.new(
      email: new_user_email, # To ensure uniqueness
      site: site,
      creation_ip: IPAddr.new("0.0.0.0")
    )
  end

  def invalid_user_registration_form
    @invalid_user_registration_form ||= User::RegistrationForm.new(
      email: nil,
      site: nil
    )
  end

  def new_user_email
    "wadus@gobierto.dev"
  end

  def user
    @user ||= users(:reed)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_validation
    assert valid_user_registration_form.valid?
  end

  def test_save
    assert valid_user_registration_form.save
  end

  def test_error_messages_with_invalid_attributes
    invalid_user_registration_form.save

    assert_equal 1, invalid_user_registration_form.errors.messages[:email].size
    assert_equal 1, invalid_user_registration_form.errors.messages[:site].size
  end

  def test_confirmation_email_delivery
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      valid_user_registration_form.save
    end
  end
end
