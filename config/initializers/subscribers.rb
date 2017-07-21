::Subscribers::SiteActivity.attach_to('activities/sites')
::Subscribers::AdminActivity.attach_to('activities/admins')
::Subscribers::CensusActivity.attach_to('activities/census')
::Subscribers::UserActivity.attach_to('activities/users')
::Subscribers::GobiertoPeopleActivity.attach_to('trackable')
::Subscribers::GobiertoBudgetConsultationsActivity.attach_to('trackable')
::Subscribers::GobiertoBudgetConsultationsConsultationResponseActivity.attach_to('activities/gobierto_budget_consultations_consultation_response')
::Subscribers::GobiertoCmsPageActivity.attach_to('activities/gobierto_cms_pages')
::Subscribers::GobiertoBudgetsBudgetLineActivity.attach_to('activities/gobierto_budgets_budget_line')
::Subscribers::GobiertoParticipationIssueActivity.attach_to('activities/gobierto_participation_issues')
::Subscribers::GobiertoCommonCollectionActivity.attach_to('activities/gobierto_common_collections')

# Custom subscribers
ActiveSupport::Notifications.subscribe(/trackable/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Rails.logger.debug("Consuming event \"#{event.name}\" with payload: #{event.payload}")

  User::Subscription::NotificationBuilder.new(event).call
end
