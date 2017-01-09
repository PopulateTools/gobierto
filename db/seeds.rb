fixtures_to_load = [
  "sites",
  "users",
  "gobierto_admin/admins",
  "user/verification/census_verifications",
  "user/subscriptions",
  "user/notifications",
  "gobierto_budget_consultations/consultations",
  "gobierto_budget_consultations/consultation_items",
  "gobierto_budget_consultations/consultation_responses",
  "gobierto_people/people",
  "gobierto_people/person_events",
  "gobierto_people/person_event_locations",
  "gobierto_people/person_event_attendees",
  "gobierto_people/person_statements",
  "gobierto_people/person_posts",
  "gobierto_common/content_blocks",
  "gobierto_common/content_block_fields",
  "gobierto_common/content_block_records"
]

ENV["FIXTURES"] = fixtures_to_load.join(",")
Rake::Task["db:fixtures:load"].invoke
Rake::Task["gobierto_people:counter_cache:reset"].invoke
