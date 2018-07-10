# frozen_string_literal: true

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
    with_signed_in_user(user) do
      notifications = user.notifications
      visit @path
    end
  end
end
