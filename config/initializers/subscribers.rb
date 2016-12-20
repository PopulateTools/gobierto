# Common subscribers (`Subscribers::Base` pattern)
Subscribers::SiteActivity.attach_to('activities/sites')

# Custom subscribers
ActiveSupport::Notifications.subscribe(/trackable/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  event_name = event.name.split(".").last
  model_name = event.payload[:gid].model_name
  model_id = event.payload[:gid].model_id
  site_id = event.payload[:site_id]

  # TODO. Perform asynchronously.
  #
  User::NotificationBuilder.new(event_name, model_name, model_id, site_id).call
end
