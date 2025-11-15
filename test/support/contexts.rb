# frozen_string_literal: true

require "support/site_session_helpers"

def with_javascript
  ensure_app_host_blank

  Capybara.current_driver = Capybara.javascript_driver
  yield
ensure
  Capybara.reset_session!
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
  admin = params[:admin]

  if params[:js]
    ensure_app_host_blank

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

  Capybara.reset_session! if params[:js]
ensure
  factory&.teardown
  factories.each(&:teardown)

  if params[:js]
    page.driver.resize_window_to(window_handle, *default_size) if params[:window_size]
    Capybara.current_driver = Capybara.default_driver
  end
end

def ensure_app_host_blank
  return if Capybara.app_host.blank?

  message = <<-MESSAGE
 Capybara current driver is javascript_driver. This would make the browser to send a
            request to a remote application with host #{site.domain} instead of the Capybara's
            rack server. Avoid the use of with_site_host or include_host: true option combined
            with javascript driver.
  MESSAGE
  raise(Exception, message)
end
