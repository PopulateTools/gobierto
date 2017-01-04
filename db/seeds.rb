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
  "gobierto_common/content_blocks",
  "gobierto_common/content_block_fields",
  "gobierto_common/content_block_records"
]

ENV["FIXTURES"] = fixtures_to_load.join(",")
Rake::Task["db:fixtures:load"].invoke
