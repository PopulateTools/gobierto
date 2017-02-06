# Common subscribers (`Subscribers::Base` pattern)
Subscribers::SiteActivity.attach_to('activities/sites')
Subscribers::AdminActivity.attach_to('activities/admins')
Subscribers::CensusActivity.attach_to('activities/census')
Subscribers::UserActivity.attach_to('activities/users')

# Custom subscribers
ActiveSupport::Notifications.subscribe(/trackable/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Rails.logger.debug("Consuming event \"#{event.name}\" with payload: #{event.payload}")

  # TODO. Perform asynchronously.
  #
  User::Subscription::NotificationBuilder.new(
    event_name: event.name.split(".").last,
    model_name: event.payload[:gid].model_name,
    model_id: event.payload[:gid].model_id,
    site_id: event.payload[:site_id]
  ).call
end
