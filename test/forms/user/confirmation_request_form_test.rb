require "test_helper"

class User::ConfirmationRequestFormTest < ActiveSupport::TestCase
  def valid_user_confirmation_request_form
    @valid_user_confirmation_request_form ||= User::ConfirmationRequestForm.new(
      email: user.email,
      site: site
    )
  end

  def user
    @user ||= users(:reed)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_validation
    assert valid_user_confirmation_request_form.valid?
  end

  def test_save
    assert valid_user_confirmation_request_form.save
  end

  def test_confirmation_email_delivery
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      valid_user_confirmation_request_form.save
    end
  end
end
