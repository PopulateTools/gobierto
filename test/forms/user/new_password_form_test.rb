# frozen_string_literal: true

require "test_helper"

class User::NewPasswordFormTest < ActiveSupport::TestCase
  def valid_user_new_password_form
    @valid_user_new_password_form ||= User::NewPasswordForm.new(
      email: user.email,
      site: site
    )
  end

  def invalid_user_new_password_form
    @invalid_user_new_password_form ||= User::NewPasswordForm.new(
      email: other_site_user.email,
      site: site
    )
  end

  def user
    @user ||= users(:reed)
  end

  def other_site_user
    @other_site_user ||= users(:charles)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_validation
    assert valid_user_new_password_form.valid?
    refute invalid_user_new_password_form.valid?
  end

  def test_save
    assert valid_user_new_password_form.save
  end

  def test_reset_password_email_delivery
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      valid_user_new_password_form.save
    end
  end
end
