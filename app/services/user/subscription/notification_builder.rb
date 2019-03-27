# frozen_string_literal: true

class User::Subscription::NotificationBuilder
  attr_reader :event_name, :site_id, :subject

  def initialize(event)
    @subject = GlobalID::Locator.locate(event.payload[:gid])
    event_name = event.name.split(".").last
    if %W(visibility_level_changed state_changed).include?(event_name)
      event_name = "published"
    end
    @event_name = subject.class.name.underscore.tr("/", ".") + "." + event_name
    @site_id = event.payload[:site_id]
  end

  def call
    [].tap do |user_notifications|
      User::Notification.transaction do
        User::Subscription::Finder.subscriptions_for(subject.class.name, (subject.id unless subject.is_a?(Class) || subject.is_a?(Module)), site_id).each do |user_id|
          user_notification = build_user_notification_for(user_id)
          if user_notification.save
            user_notifications.push(user_notification.record)
          end
        end
      end
    end
  end

  private

  def build_user_notification_for(user_id)
    User::NotificationForm.new(
      user_id: user_id,
      site_id: site_id,
      action: event_name,
      subject: subject
    )
  end
end
