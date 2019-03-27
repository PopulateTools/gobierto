# frozen_string_literal: true

class User::NotificationMailer < ApplicationMailer
  def single_notification(user_notification)
    @user_notification = user_notification
    @user_notification_decorated = UserNotificationDecorator.new(user_notification)

    @user = user_notification.user
    @site = user_notification.site

    @site_host = site_host

    mail(
      from: from,
      reply_to: default_reply_to,
      to: @user.email,
      subject: t(".subject", site_name: @site.name, action_name: @user_notification_decorated.subject_name)
    )
  end

  def notification_digest(user, user_notifications, frequency)
    @user = user
    @user_notifications = UserNotificationCollectionDecorator.new(user_notifications)
    @site = user_notifications.first.site
    @site_host = site_host

    mail(
      from: from,
      reply_to: default_reply_to,
      to: @user.email,
      subject: t(".subject", site_name: @site.name)
    )
  end
end
