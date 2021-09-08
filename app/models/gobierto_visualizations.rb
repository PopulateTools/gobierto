# frozen_string_literal: true

module GobiertoVisualizations
  def self.root_path(current_site)
    return unless (module_settings = current_site.gobierto_visualizations_settings)

    home_key = find_home_key(module_settings.settings&.dig("visualizations_config", "visualizations"))

    Rails.application.routes.url_helpers.send("gobierto_visualizations_#{home_key}_path")
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

  def self.find_home_key(settings)
    return unless settings.present?

    settings.find { |_key, config| config["home"] }[0]
  end
end
