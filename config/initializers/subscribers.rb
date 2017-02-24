# Common subscribers (`Subscribers::Base` pattern)
::Subscribers::SiteActivity.attach_to('activities/sites')
::Subscribers::AdminActivity.attach_to('activities/admins')
::Subscribers::CensusActivity.attach_to('activities/census')
::Subscribers::UserActivity.attach_to('activities/users')
::Subscribers::GobiertoPeopleActivity.attach_to('trackable')
::Subscribers::GobiertoCmsPageActivity.attach_to('activities/gobierto_cms_pages')

# Custom subscribers
ActiveSupport::Notifications.subscribe(/trackable/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Rails.logger.debug("Consuming event \"#{event.name}\" with payload: #{event.payload}")

  User::Subscription::NotificationBuilder.new(event).call
end
