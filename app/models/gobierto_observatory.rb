# frozen_string_literal: true

module GobiertoObservatory
  def self.doc_url
    "https://gobierto.readme.io/docs/observatorio"
  end

  def self.root_path(_)
    Rails.application.routes.url_helpers.gobierto_observatory_root_path
  end

  def self.default_observatory_configuration_settings
    <<JSON
    {
      "observatory": {
        "map": {
          "enabled": false,
          "center": {
            "lat": "",
            "lon": ""
          }
        }
      }
    }
JSON
  end

end
