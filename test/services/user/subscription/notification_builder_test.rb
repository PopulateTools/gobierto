require "test_helper"

class User::Subscription::NotificationBuilderTest < ActiveSupport::TestCase
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

  def published_event
    OpenStruct.new name: 'trackable.visibility_level_changed', payload: {
      site_id: site.id,
      gid: subscribable.to_gid
    }
  end

  def updated_event
    OpenStruct.new name: 'trackable.updated', payload: {
      site_id: site.id,
      gid: subscribable.to_gid
    }
  end

  def test_updated_event
    subject = User::Subscription::NotificationBuilder.new(updated_event)
    user_notifications = subject.call
    first_user_notification = user_notifications.first

    assert_equal 1, user_notifications.size
    assert_equal User::Notification, first_user_notification.class
    assert_equal user.id, first_user_notification.user_id
    assert_equal site.id, first_user_notification.site_id
    assert_equal "gobierto_budget_consultations.consultation.updated", first_user_notification.action
    assert_equal subscribable.model_name.to_s, first_user_notification.subject_type
    assert_equal subscribable.id, first_user_notification.subject_id
  end

  def test_published_event
    subject = User::Subscription::NotificationBuilder.new(published_event)
    user_notifications = subject.call
    first_user_notification = user_notifications.first

    assert_equal 1, user_notifications.size
    assert_equal User::Notification, first_user_notification.class
    assert_equal user.id, first_user_notification.user_id
    assert_equal site.id, first_user_notification.site_id
    assert_equal "gobierto_budget_consultations.consultation.published", first_user_notification.action
    assert_equal subscribable.model_name.to_s, first_user_notification.subject_type
    assert_equal subscribable.id, first_user_notification.subject_id
  end
end
