require "test_helper"

class User::NotificationFormTest < ActiveSupport::TestCase
  def valid_user_notification_form
    @valid_user_notification_form ||= User::NotificationForm.new(
      user_id: user.id,
      site_id: site.id,
      action: action,
      subject_type: subject.model_name.to_s,
      subject_id: subject.id
    )
  end

  def invalid_user_notification_form
    @invalid_user_notification_form ||= User::NotificationForm.new(
      user_id: nil,
      site_id: nil,
      action: nil,
      subject_type: nil,
      subject_id: nil
    )
  end

  def action
    "created"
  end

  def user
    @user ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  def subject
    @subject ||= gobierto_budget_consultations_consultations(:madrid_open)
  end

  def test_validation
    assert valid_user_notification_form.valid?
  end

  def test_error_messages_with_invalid_attributes
    invalid_user_notification_form.save

    assert_equal 1, invalid_user_notification_form.errors.messages[:user_id].size
    assert_equal 1, invalid_user_notification_form.errors.messages[:site_id].size
    assert_equal 1, invalid_user_notification_form.errors.messages[:action].size
    assert_equal 1, invalid_user_notification_form.errors.messages[:subject_type].size
    assert_equal 1, invalid_user_notification_form.errors.messages[:subject_id].size
  end

  def test_save
    assert valid_user_notification_form.save
  end

  def test_resource_creation
    assert_difference "User::Notification.count", 1 do
      valid_user_notification_form.save
    end
  end

  def test_notification_email_delivery
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      valid_user_notification_form.save
    end
  end
end
