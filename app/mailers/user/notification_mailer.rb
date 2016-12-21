class User::NotificationMailer < ApplicationMailer
  helper User::NotificationsHelper

  def single_notification(user_notification)
    @user_notification = user_notification

    @user = user_notification.user
    @site = user_notification.site
    @subject = user_notification.subject
    @action = user_notification.action

    mail(
      from: default_from,
      reply_to: default_reply_to,
      to: @user.email,
      subject: I18n.t("#{user_notification.subject.model_name.i18n_key}.notifications.subject.#{user_notification.action}"),
      template_path: "#{user_notification.subject.model_name.collection}/notifications",
      template_name: user_notification.action
    )
  end

  def notification_digest(user, user_notifications, frequency)
    @user = user
    @user_notifications = user_notifications

    mail(
      from: default_from,
      reply_to: default_reply_to,
      to: @user.email,
      subject: default_i18n_subject(frequency: frequency)
    )
  end
end
