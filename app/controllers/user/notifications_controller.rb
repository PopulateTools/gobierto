class User::NotificationsController < User::BaseController
  before_action :authenticate_user!

  def index
    @user_notifications = find_user_notifications.sorted
  end

  private

  def find_user_notifications
    User::Notification.where(
      user: current_user,
      site: current_site
    )
  end
end
