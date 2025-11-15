# frozen_string_literal: true

# For debugging in development
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.args << "--explicitly-allowed-ports=#{Capybara.server_port}"
  options.args << "--headless=new"
  options.args << "--disable-search-engine-choice-screen" # Prevents closing the window normally
  # Do not limit browser resources
  options.args << "--disable-dev-shm-usage"
  options.args << "--no-sandbox"
  options.args << "--window-size=1920,3000"
  options.args << "--ignore-certificate-errors" if ENV["TEST_SSL"]
  # Additional args to improve stability
  options.args << "--disable-gpu"
  options.args << "--disable-extensions"
  options.args << "--disable-web-security"
  options.args << "--disable-features=VizDisplayCompositor"

  options.add_preference(:browser, set_download_behavior: { behavior: "allow" })

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options:
  )
end
