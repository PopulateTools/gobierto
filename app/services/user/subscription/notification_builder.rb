class User::Subscription::NotificationBuilder
  GENERIC_EVENT_NAMES = %w(created)

  attr_reader :event_name, :model_name, :model_id, :site_id

  def initialize(event_name:, model_name:, model_id:, site_id:)
    @event_name = event_name
    @model_name = model_name
    @model_id = model_id
    @site_id = site_id
  end

  def call
    user_notifications = []

    User::Notification.transaction do
      User::Subscription
        .select(:id, :user_id)
        .where(
          subscribable_type: model_name,
          subscribable_id: (model_id unless generic_event?),
          site_id: site_id
        )
        .find_each do |user_subscription|
          user_notification = build_user_notification_for(user_subscription.user_id)

          if user_notification.save
            user_notifications << user_notification.record
          end
        end
    end

    user_notifications
  end

  private

  def build_user_notification_for(user_id)
    User::NotificationForm.new(
      user_id: user_id,
      site_id: site_id,
      action: event_name,
      subject_type: model_name,
      subject_id: model_id
    )
  end

  def generic_event?
    GENERIC_EVENT_NAMES.include?(event_name)
  end
end
