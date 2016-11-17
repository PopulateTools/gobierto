fixtures_to_load = [
  "sites",
  "admins",
  "users"
]

ENV["FIXTURES"] = fixtures_to_load.join(",")
Rake::Task["db:fixtures:load"].invoke
