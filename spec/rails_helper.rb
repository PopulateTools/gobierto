ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'email_spec'
require 'rack/test'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  config.include(Factories)
  config.include(Paths)
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)

  Capybara.javascript_driver = :selenium
  Capybara.default_max_wait_time = 5
  Capybara.server_port = 31337

  Delayed::Worker.delay_jobs = false

  config.before(:suite) do
    %x[bundle exec rake assets:precompile]

    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:transaction)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.after(:each) do
    Timecop.return
    reset_mailer
  end
end
