# frozen_string_literal: true

Capybara.register_driver :poltergeist_custom do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    timeout: 300,
    inspector: ENV["INTEGRATION_INSPECTOR"] == "true",
    debug: ENV["INTEGRATION_DEBUG"] == "true",
    window_size: [1920, 6000]
  )
end

# For debugging in development
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu) }
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end
