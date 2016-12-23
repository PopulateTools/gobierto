require "test_helper"

class User::NotificationsHelperTest < ActionView::TestCase
  def user_notification
    @user_notification ||= user_notifications(:dennis_consultation_created)
  end

  def subject
    @subject ||= user_notification.subject
  end

  def test_render_notification_item
    notification_item_markup =
      "<span>" \
        "A consultation has been added: " \
        "#{link_to(subject.subscribable_label, subject)}" \
      "</span>"

    assert_equal(
      notification_item_markup,
      render_notification_item(user_notification, false)
    )
  end

  def test_render_notification_item_with_absolute_url
    notification_item_markup =
      "<span>" \
        "A consultation has been added: " \
        "#{link_to(subject.subscribable_label, polymorphic_url(subject, domain: subject.site.domain))}" \
      "</span>"

    assert_equal(
      notification_item_markup,
      render_notification_item(user_notification, true)
    )
  end
end
