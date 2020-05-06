# frozen_string_literal: true

module GobiertoDashboards
  def self.root_path(current_site)
    Rails.application.routes.url_helpers.gobierto_dashboards_root_path
  end

  def self.default_dashboards_configuration_settings
    <<JSON
    {
      "dashboards": {
        "contracts": {
          "enabled": false,
          "data_urls": {
            "endpoint": ""
          }
        },
        "tenders": {
          "enabled": false,
          "data_urls": {
            "endpoint": ""
          }
        }
      }
    }
JSON
  end
end
