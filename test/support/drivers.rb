# frozen_string_literal: true

# For debugging in development
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new
  options.args << "--headless"
  options.args << "--no-sandbox"
  options.args << "--window-size=1920,3000"

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end
