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

    run_callbacks if create_notification
  end

  def record
    user_notification
  end

  private

  def user_notification
    @user_notification ||= User::Notification.new
  end

  def run_callbacks
    true
  end

  def create_notification
    @notification = user_notification.tap do |user_notification_attributes|
      user_notification_attributes.user_id = user_id
      user_notification_attributes.site_id = site_id
      user_notification_attributes.action = action
      user_notification_attributes.subject_type = subject_type
      user_notification_attributes.subject_id = subject_id
    end

    @notification.save(validate: false)
  end
end
