class User::NotificationForm
  include ActiveModel::Model

  attr_accessor(
    :user_id,
    :site_id,
    :action,
    :subject_type,
    :subject_id
  )

  validates :user_id, :site_id, :action, :subject_type, :subject_id, presence: true

  def save
    return unless valid?

    run_callbacks if save_user_notification
  end

  def user_notification
    @user_notification ||= User::Notification.new
  end
  alias record user_notification

  private

  def user
    user_notification.user
  end

  def run_callbacks
    return true unless deliver_notification_email?

    deliver_notification_email
    mark_as_sent
  end

  def save_user_notification
    @user_notification = user_notification.tap do |user_notification_attributes|
      user_notification_attributes.user_id = user_id
      user_notification_attributes.site_id = site_id
      user_notification_attributes.action = action
      user_notification_attributes.subject_type = subject_type
      user_notification_attributes.subject_id = subject_id
    end

    @user_notification.save(validate: false)
  end

  protected

  def deliver_notification_email?
    user.immediate_notifications?
  end

  def deliver_notification_email
    User::NotificationMailer.single_notification(user_notification).deliver_later
  end

  def mark_as_sent
    user_notification.sent!
  end
end
