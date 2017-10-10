# frozen_string_literal: true

fixtures_to_load = [
  "sites",
  "users",
  "census_items",
  "gobierto_module_settings",
  "gobierto_admin/admins",
  "user/verification/census_verifications",
  "user/subscriptions",
  "user/notifications",
  "gobierto_budgets/categories",
  "gobierto_budget_consultations/consultations",
  "gobierto_budget_consultations/consultation_items",
  "gobierto_budget_consultations/consultation_responses",
  "gobierto_people/people",
  "gobierto_people/person_statements",
  "gobierto_people/person_posts",
  "gobierto_people/political_groups",
  "gobierto_common/collections",
  "gobierto_calendars/events",
  "gobierto_calendars/event_locations",
  "gobierto_calendars/event_attendees",
  "gobierto_cms/pages",
  "gobierto_attachments/attachments",
  "gobierto_attachments/attachings",
  "versions",
  "gobierto_participation/processes",
  "gobierto_participation/process_stages",
  "gobierto_participation/polls",
  "gobierto_participation/poll_questions",
  "gobierto_participation/poll_answer_templates",
  "gobierto_participation/poll_answers",
  "issues",
  "gobierto_participation/areas",
  "gobierto_common/collection_items",
  "gobierto_common/scopes"
]

ENV["FIXTURES"] = fixtures_to_load.join(",")
Rake::Task["db:fixtures:load"].invoke
::GobiertoCommon::ContentBlock.reset_column_information
Rake::Task["gobierto_people:counter_cache:reset"].invoke

GobiertoPeople::PoliticalGroup.reset_position!

::GobiertoCommon::ContentBlock.reset_column_information

Site.all.each do |site|
  if site.configuration.gobierto_people_enabled?
    GobiertoCommon::GobiertoSeeder::ModuleSeeder.seed("GobiertoPeople", site)
    GobiertoCommon::GobiertoSeeder::ModuleSiteSeeder.seed(APP_CONFIG["site"]["name"], "GobiertoPeople", site)
  end
end
