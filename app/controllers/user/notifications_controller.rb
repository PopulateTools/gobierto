class User::NotificationsController < User::BaseController
  before_action :authenticate_user!
  after_action :mark_as_seen, only: :index

  def index
    @user_notifications = find_user_notifications.sorted.limit(30)
  end

  private

  def find_user_notifications
    User::Notification.unseen.where(user: current_user, site: current_site)
  end

  def mark_as_seen
    @user_notifications.seen!
  end
end
