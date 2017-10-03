# frozen_string_literal: true

require_dependency Rails.root.join("app/subscribers/base")
Dir.glob("app/subscribers/*.rb").each do |subscriber_path|
  require_dependency Rails.root.join(subscriber_path)
end

Subscribers::AdminActivity.attach_to("activities/admins")
Subscribers::CensusActivity.attach_to("activities/census")
Subscribers::GobiertoPeopleActivity.attach_to("trackable")
Subscribers::GobiertoBudgetConsultationsActivity.attach_to("trackable")
Subscribers::GobiertoCalendarsActivity.attach_to("trackable")
Subscribers::GobiertoBudgetConsultationsConsultationResponseActivity.attach_to("activities/gobierto_budget_consultations_consultation_response")
Subscribers::GobiertoCmsPageActivity.attach_to("activities/gobierto_cms_pages")
Subscribers::GobiertoBudgetsBudgetLineActivity.attach_to("activities/gobierto_budgets_budget_line")
Subscribers::GobiertoCommonCollectionActivity.attach_to("activities/gobierto_common_collections")
Subscribers::GobiertoAttachmentsAttachmentActivity.attach_to("activities/gobierto_attachments_attachments")
Subscribers::IssueActivity.attach_to("activities/issues")
Subscribers::ScopeActivity.attach_to("activities/scopes")
Subscribers::GobiertoParticipationProcessActivity.attach_to("activities/gobierto_participation_processes")
Subscribers::GobiertoParticipationPollActivity.attach_to("activities/gobierto_participation_polls")
Subscribers::GobiertoParticipationContributionContainerActivity.attach_to("activities/gobierto_participation_contribution_containers")
Subscribers::UserActivity.attach_to("activities/users")
Subscribers::SiteActivity.attach_to("activities/sites")

# Custom subscribers
ActiveSupport::Notifications.subscribe(/trackable/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Rails.logger.debug("Consuming event \"#{event.name}\" with payload: #{event.payload}")

  User::Subscription::NotificationBuilder.new(event).call
end
