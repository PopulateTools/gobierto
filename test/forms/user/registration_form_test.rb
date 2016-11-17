require "test_helper"

class User::RegistrationFormTest < ActiveSupport::TestCase
  def valid_user_registration_form
    @valid_user_registration_form ||= User::RegistrationForm.new(
      email: new_user_email, # To ensure uniqueness
      name: user.name,
      password: "wadus",
      password_confirmation: "wadus",
      site: site,
      creation_ip: IPAddr.new("0.0.0.0")
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

  def test_confirmation_email_delivery
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      valid_user_registration_form.save
    end
  end
end
