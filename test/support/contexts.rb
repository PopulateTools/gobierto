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

def check_js_errors!(page)
  js_errors = page.driver.browser.manage.logs.get(:browser)
                  .select { |e| e.level == "SEVERE" }

  if js_errors.any?
    messages = js_errors.map { |e| "[#{e.level}] #{e.message}" }.join("\n")
    raise "JS errors where raised:\n\n#{messages}\n"
  end
end

def with(params = {})
  factory = params[:factory]
  factories = params[:factories] || []
  admin = params[:admin]

  if params[:js]
    Capybara.current_driver = Capybara.javascript_driver

    if params[:window_size] == :xl
      window_handle = page.driver.window_handles.first
      default_size = page.driver.window_size(window_handle)
      page.driver.resize_window_to(window_handle, 2000, 2000)
    end
  end

  sign_in_admin(admin) if admin

  if (site = params[:site])
    stub_current_site(site) { yield }
  else
    yield(params)
  end

  if params[:js]
    check_js_errors!(page)
    Capybara.reset_session!
  end
ensure
  sign_out_admin if admin
  factory&.teardown
  factories.each(&:teardown)

  if params[:js]
    page.driver.resize_window_to(window_handle, *default_size) if params[:window_size]
    Capybara.current_driver = Capybara.default_driver
  end
end
