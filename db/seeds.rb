fixtures_to_load = [
  "sites",
  "users",
  "gobierto_admin/admins"
]

ENV["FIXTURES"] = fixtures_to_load.join(",")
Rake::Task["db:fixtures:load"].invoke
