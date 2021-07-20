# frozen_string_literal: true

require "test_helper"

class User::NotificationFormTest < ActiveSupport::TestCase
  def valid_user_notification_form
    @valid_user_notification_form ||= User::NotificationForm.new(
      user_id: user.id,
      site_id: site.id,
      action: action,
      subject: subject
    )
  end

  def valid_delayed_user_notification_form
    @valid_delayed_user_notification_form ||= User::NotificationForm.new(
      user_id: delayed_notifications_user.id,
      site_id: site.id,
      action: action,
      subject: subject
    )
  end

  def invalid_user_notification_form
    @invalid_user_notification_form ||= User::NotificationForm.new(
      user_id: nil,
      site_id: nil,
      action: nil,
      subject: nil
    )
  end

  def action
    "created"
  end

  def user
    @user ||= users(:susan)
  end

  def delayed_notifications_user
    @delayed_notifications_user ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= gobierto_people_person_posts(:richard_about_me)
  end

  def test_validation
    assert valid_user_notification_form.valid?
  end

  def test_error_messages_with_invalid_attributes
    invalid_user_notification_form.save

    assert_equal 1, invalid_user_notification_form.errors.messages[:user_id].size
    assert_equal 1, invalid_user_notification_form.errors.messages[:site_id].size
    assert_equal 1, invalid_user_notification_form.errors.messages[:action].size
    assert_equal 1, invalid_user_notification_form.errors.messages[:subject].size
  end

  def test_save
    assert valid_user_notification_form.save
  end

  def test_resource_creation
    assert_difference "User::Notification.count", 1 do
      valid_user_notification_form.save
    end
  end

  def test_immediate_notification_email_delivery
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      valid_user_notification_form.save
    end
  end

  def test_delayed_notification_email_delivery
    assert_no_difference "ActionMailer::Base.deliveries.size" do
      valid_delayed_user_notification_form.save
    end
  end
end
