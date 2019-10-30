# frozen_string_literal: true

module AppHostHelpers
  def with_site_host(site)
    if javascript_driver?
      message = <<-MESSAGE
 Capybara current driver is javascript_driver. This would make the browser to send a
            request to a remote application with host #{site.domain} instead of the Capybara's
            rack server. Avoid the use of with_site_host or include_host: true option combined
            with javascript driver.
      MESSAGE
      raise(Exception, message)
    end

    original_host = Capybara.app_host
    Capybara.app_host = root_url(host: site.domain).gsub(/\/$/, '')
    yield
  ensure
    Capybara.app_host = original_host
  end
end
