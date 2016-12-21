module User::NotificationsHelper
  def render_notification_item(user_notification, absolute_url = false)
    content_tag :span do
      capture do
        concat(
          I18n.t(
            "#{user_notification.subject.model_name.i18n_key}.notifications.subject.#{user_notification.action}"
          )
        )
        concat(
          ": "
        )
        concat(
          link_to(
            user_notification.subject.subscribable_label,
            polymorphic_url(
              user_notification.subject,
              domain: (user_notification.site.domain if absolute_url)
            )
          )
        )
      end
    end
  end
end
