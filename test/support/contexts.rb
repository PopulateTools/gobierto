# frozen_string_literal: true

require "support/site_session_helpers"

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

def with(params = {})
  factory = params[:factory]
  factories = params[:factories] || []
  js_driver = js_driver(params[:js])
  admin = params[:admin]

  Capybara.current_driver = js_driver if params[:js]
  sign_in_admin(admin) if admin

  if (site = params[:site])
    stub_current_site(site) { yield }
  else
    yield(params)
  end

  sign_out_admin if admin
  Capybara.reset_session! if params[:js]
ensure
  factory&.teardown
  factories.each(&:teardown)
  Capybara.current_driver = Capybara.default_driver if params[:js]
end

def js_driver(param)
  return unless param

  if param == :deprecated
    :poltergeist_custom
  else
    (ENV["INTEGRATION_TEST_DRIVER"] || :headless_chrome).to_sym
  end
end
