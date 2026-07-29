# frozen_string_literal: true

# Capybara keeps a single browser alive for the whole run and only clears
# cookies and storage between tests -- never the HTTP cache. Public pages ship
# `Cache-Control: public, max-age=...` (see HttpCache), so a page fetched by one
# test is served from cache to the next test that visits the same URL, even
# though the server state changed in between. Turn the browser cache off so each
# test really hits the app.
#
# Re-applied whenever the browser is (re)created: `@browser` is nil before the
# first command and again after a crash or an explicit quit.
def disable_http_cache_on_browser_start(driver)
  def driver.browser
    browser_already_started = !@browser.nil?

    super.tap do |browser|
      next if browser_already_started

      browser.execute_cdp("Network.enable")
      browser.execute_cdp("Network.setCacheDisabled", cacheDisabled: true)
    end
  end

  driver
end

# For debugging in development
Capybara.register_driver :chrome do |app|
  disable_http_cache_on_browser_start(
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  )
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

  disable_http_cache_on_browser_start(
    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options:
    )
  )
end
