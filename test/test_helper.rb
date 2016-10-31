ENV["RAILS_ENV"] = "test"
ENV["DOMAIN"] = "127.0.0.1"

require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "minitest/rails/capybara"
require "minitest/mock"
require "minitest/reporters"
require "capybara/poltergeist"
require "sidekiq/testing"
require "webmock/minitest"

Capybara.register_driver :poltergeist_custom do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    timeout: 300,
    debug: ENV["CAPYBARA_DEBUG"] == "true")
end

Capybara.javascript_driver = :poltergeist_custom

DatabaseCleaner.strategy = :transaction
DatabaseCleaner.clean_with :truncation

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

I18n.locale = I18n.default_locale = :en

class ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include TenancyHelpers
  include SmsClientHelpers
  include BitlyClientHelpers

  fixtures :all

  ActiveRecord::Migration.check_pending!
  WebMock.disable_net_connect!(
    allow_localhost: true
  )

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Warden::Test::Helpers
  include SessionHelpers

  Warden.test_mode!

  self.use_transactional_fixtures = false

  def setup
    super
  end

  def teardown
    super

    Warden.test_reset!
  end
end
