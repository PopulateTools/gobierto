require "test_helper"

class User::SubscriptionFormTest < ActiveSupport::TestCase
  def valid_user_subscription_form
    @valid_user_subscription_form ||= User::SubscriptionForm.new(
      user: user,
      site: site,
      subscribable: subscribable,
      creation_ip: IPAddr.new("0.0.0.0")
    )
  end

  def valid_new_user_subscription_form
    @valid_new_user_subscription_form ||= User::SubscriptionForm.new(
      user_email: new_user_email,
      site: site,
      subscribable: subscribable,
      creation_ip: IPAddr.new("0.0.0.0")
    )
  end

  def invalid_user_subscription_form
    @invalid_user_subscription_form ||= User::SubscriptionForm.new(
      user: nil,
      site: nil,
      subscribable: nil
    )
  end

  def invalid_new_user_subscription_form
    @invalid_new_user_subscription_form ||= User::SubscriptionForm.new(
      user_email: nil,
      site: nil,
      subscribable: nil
    )
  end

  def new_user_email
    "wadus@gobierto.dev"
  end

  def user
    @user ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  # Let's use a gobierto-core resource as `subscribable`.
  #
  def subscribable
    @subscribable ||= users(:reed)
  end

  def test_validation
    assert valid_user_subscription_form.valid?
    assert valid_new_user_subscription_form.valid?
  end

  def test_save
    assert valid_user_subscription_form.save
    assert valid_new_user_subscription_form.save
  end

  def test_error_messages_with_invalid_attributes
    invalid_user_subscription_form.save

    assert_equal 1, invalid_user_subscription_form.errors.messages[:email].size
    assert_equal 2, invalid_user_subscription_form.errors.messages[:site].size
    assert_equal 1, invalid_user_subscription_form.errors.messages[:subscribable].size
  end

  def test_error_messages_with_invalid_attributes_in_new_user_form
    invalid_new_user_subscription_form.save

    assert_equal 1, invalid_new_user_subscription_form.errors.messages[:email].size
    assert_equal 2, invalid_new_user_subscription_form.errors.messages[:site].size
    assert_equal 1, invalid_new_user_subscription_form.errors.messages[:subscribable].size
  end

  def test_user_registration
    assert_difference "User.count", 1 do
      valid_new_user_subscription_form.save
    end
  end
end
