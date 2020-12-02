# frozen_string_literal: true

module GobiertoVisualizations
  def self.root_path(current_site)
    Rails.application.routes.url_helpers.gobierto_visualizations_root_path
  end

  def self.default_visualizations_configuration_settings
    <<JSON
    {
      "visualizations": {
        "contracts": {
          "enabled": false,
          "data_urls": {
            "contracts": "",
            "tenders": ""
          }
        },
        "subsidies": {
          "enabled": false,
          "data_urls": {
            "subsidies": ""
          }
        }
      }
    }
JSON
  end
end
