# frozen_string_literal: true

module AppHostHelpers
  def with_site_host(site)
    original_host = Capybara.app_host
    Capybara.app_host = root_url(host: site.domain).gsub(/\/$/, '')
    yield
  ensure
    Capybara.app_host = original_host
  end
end
