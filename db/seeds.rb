fixtures_to_load = [
  "sites",
  "users",
  "gobierto_admin/admins",
  "user/verification/census_verifications",
  "user/subscriptions",
  "gobierto_budget_consultations/consultations",
  "gobierto_budget_consultations/consultation_items",
  "gobierto_budget_consultations/consultation_responses"
]

ENV["FIXTURES"] = fixtures_to_load.join(",")
Rake::Task["db:fixtures:load"].invoke
