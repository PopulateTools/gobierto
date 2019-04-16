# frozen_string_literal: true

def with_chrome_driver
  Capybara.current_driver = ENV["INTEGRATION_TEST_DRIVER"].to_sym || :headless_chrome
  yield
  Capybara.reset_session!
ensure
  Capybara.current_driver = Capybara.default_driver
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
