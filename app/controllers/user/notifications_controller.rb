# frozen_string_literal: true

class User::NotificationsController < User::BaseController
  before_action :authenticate_user!

  def index
    user_notifications = find_user_notifications.sorted.limit(30)
    user_notifications.seen!
    @user_notifications = UserNotificationCollectionDecorator.new(user_notifications)
  end

  private

  def find_user_notifications
    User::Notification.where(user: current_user, site: current_site)
  end
end
