module User::NotificationsHelper
  def render_notification_item(user_notification)
    subject = user_notification.subject
    action = user_notification.action

    render(
      "user/notifications/#{subject.model_name}".underscore,
      subject: subject,
      action: action
    )
  end
end
