require "test_helper"

class User::NotificationIndexTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = user_notifications_path
  end

  def user
    @user ||= users(:dennis)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_notification_index
    with_current_site(site) do
      with_signed_in_user(user) do
        unseen_notifications = user.notifications.unseen
        visit @path

        within ".user-notification-list" do
          unseen_notifications.each do |user_notification|
            assert has_selector?(
              "tr#user-notification-item-#{user_notification.id}",
              text: user_notification.subject.subscribable_label
            )
          end
        end
      end
    end
  end

  def test_notification_seen_flagging
    with_current_site(site) do
      with_signed_in_user(user) do
        visit @path
        assert has_selector?(".user-notification-list")
        refute has_content?("There are no new notifications")

        visit @path
        refute has_selector?(".user-notification-list")
        assert has_content?("There are no new notifications")
      end
    end
  end
end
