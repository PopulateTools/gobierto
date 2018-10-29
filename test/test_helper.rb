# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
ENV["DISABLE_DATABASE_ENVIRONMENT_CHECK"] = "1"
ENV["HOST"] = "www.example.com"

if ENV["CI"] || ENV["RUN_COVERAGE"]
  require "simplecov"
  SimpleCov.start "rails" do
    add_filter "app/models/concerns"
    add_filter "app/controllers/concerns"

    add_group "Controllers", "app/controllers"
    add_group "Models", "app/models"
    add_group "Forms", "app/forms"
    add_group "Services", "app/services"
    add_group "Decorators", "app/decorators"
    add_group "Presenters", "app/presenters"
    add_group "Repositories", "app/repositories"
    add_group "Publishers", "app/publishers"
    add_group "Jobs", "app/jobs"
    add_group "Policies", "app/policies"
    add_group "Helpers", "app/helpers"
    add_group "Mailers", "app/mailers"
    add_group "Views", "app/views"
  end
end

if ENV["CI"]
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/mock"
require "minitest/reporters"
require "spy/integration"
require "webmock/minitest"
require "support/common_helpers"
require "support/session_helpers"
require "support/site_session_helpers"
require "support/app_host_helpers"
require "support/message_delivery_helpers"
require "support/gobierto_site_constraint_helpers"
require "support/asymmetric_encryptor_helpers"
require "support/site_config_helpers"
require "support/gobierto_people/submodules_helper"
require "capybara/email"
require "capybara/rails"
require "capybara/minitest"
require "minitest/retry"
require "vcr"
require "mocha/minitest"

I18n.default_locale = :en
Time.zone = "Madrid"

Minitest::Retry.use! if ENV["RETRY_FAILING_TEST"]
Minitest::Retry.on_failure do |klass, test_name|
  Capybara.reset_session!
end

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new(color: true)

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: "elasticsearch"
)

VCR.configure do |c|
  c.cassette_library_dir = "test/vcr_cassettes"
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end

ActiveRecord::Migration.maintain_test_schema!

class ActiveSupport::TestCase
  include CommonHelpers
  include SessionHelpers
  include AppHostHelpers
  include SiteSessionHelpers
  include ActiveJob::TestHelper

  fixtures :all

  AVAILABLE_LOCALES = I18n.available_locales - [:en]

  self.use_transactional_tests = true

  def setup
    I18n.locale = I18n.default_locale
  end

  def teardown
    mocha_teardown
  end
end

class ActionDispatch::IntegrationTest
  require "capybara/poltergeist"
  require "support/integration/authentication_helpers"
  require "support/integration/site_session_helpers"
  require "support/integration/matcher_helpers"
  require "support/integration/page_helpers"
  require "support/file_uploader_helpers"
  require "support/permission_helpers"

  include Capybara::DSL
  include Integration::AuthenticationHelpers
  include Integration::SiteSessionHelpers
  include Integration::MatcherHelpers
  include Integration::PageHelpers
  include Capybara::Email::DSL
  include FileUploaderHelpers
  include GobiertoPeople::SubmodulesHelper

  Capybara.register_driver :poltergeist_custom do |app|
    Capybara::Poltergeist::Driver.new(
      app,
      timeout: 300,
      inspector: ENV["INTEGRATION_INSPECTOR"] == "true",
      debug: ENV["INTEGRATION_DEBUG"] == "true",
      window_size: [1920, 6000]
    )
  end

  Capybara.javascript_driver = :poltergeist_custom
  Capybara.default_host = "http://gobierto.test"

  self.use_transactional_tests = true

  def setup
    $redis.flushdb
    Capybara.current_driver = Capybara.default_driver
  end

  def teardown
    Capybara.reset_session!
  end

  def with_javascript
    Capybara.current_driver = Capybara.javascript_driver
    yield
    Capybara.reset_session!
  ensure
    Capybara.current_driver = Capybara.default_driver
  end

  def with_hidden_elements
    Capybara.ignore_hidden_elements = false
    yield
  ensure
    Capybara.ignore_hidden_elements = true
  end

  def javascript_driver?
    Capybara.current_driver == Capybara.javascript_driver
  end

  def default_driver?
    Capybara.current_driver == Capybara.default_driver
  end
end

class GobiertoControllerTest < ActionDispatch::IntegrationTest
  require "support/integration/request_authentication_helpers"

  include Integration::RequestAuthenticationHelpers
end
