ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "minitest/mock"
require "minitest/reporters"
require "database_cleaner"
require "support/session_helpers"
require "support/site_session_helpers"
require "spy/integration"
require "support/message_delivery_helpers"

I18n.locale = I18n.default_locale = :en
Time.zone = "UTC"

DatabaseCleaner.strategy = :transaction
DatabaseCleaner.clean_with :truncation

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

ActiveRecord::Migration.maintain_test_schema!
ActiveRecord::Migration.check_pending!

class ActiveSupport::TestCase
  include SessionHelpers
  include SiteSessionHelpers
  include ActiveJob::TestHelper

  fixtures :all
  set_fixture_class admin_global_permissions: Admin::Permission::Global
  set_fixture_class admin_census_imports: Admin::CensusImport
  set_fixture_class user_census_verifications: User::Verification::CensusVerification

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end

class ActionDispatch::IntegrationTest
  require "minitest/rails/capybara"
  require "capybara/poltergeist"
  require "support/integration/authentication_helpers"
  require "support/integration/site_session_helpers"

  include Capybara::DSL
  include Integration::AuthenticationHelpers
  include Integration::SiteSessionHelpers

  Capybara.register_driver :poltergeist_custom do |app|
    Capybara::Poltergeist::Driver.new(
      app,
      timeout: 300,
      inspector: ENV["INTEGRATION_INSPECTOR"] == "true",
      debug: ENV["INTEGRATION_DEBUG"] == "true"
    )
  end

  Capybara.javascript_driver = :poltergeist_custom
  Capybara.default_host = "http://gobierto.dev"

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
    Capybara.reset_session!
  end
end
