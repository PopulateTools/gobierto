require "test_helper"

class User::Subscription::NotificationBuilderTest < ActiveSupport::TestCase
  def setup
    super
    @subject = User::Subscription::NotificationBuilder.new(
      event_name: event_name,
      model_name: subscribable.model_name.to_s,
      model_id: subscribable.id,
      site_id: site.id
    )
  end

  def user_subscription
    @user_subscription ||= user_subscriptions(:dennis_consultation_madrid_open)
  end

  def subscribable
    @subscribable ||= user_subscription.subscribable
  end

  def user
    @user ||= user_subscription.user
  end

  def site
    @site ||= subscribable.site
  end

  def event_name
    "created"
  end

  def test_call
    assert_difference "User::Notification.count", 1 do
      @subject.call
    end

    user_notifications = @subject.call
    first_user_notification = user_notifications.first

    assert_equal 1, user_notifications.size
    assert_equal User::Notification, first_user_notification.class
    assert_equal user.id, first_user_notification.user_id
    assert_equal site.id, first_user_notification.site_id
    assert_equal event_name, first_user_notification.action
    assert_equal subscribable.model_name.to_s, first_user_notification.subject_type
    assert_equal subscribable.id, first_user_notification.subject_id
  end
end
