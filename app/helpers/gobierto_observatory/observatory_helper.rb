# frozen_string_literal: true

module GobiertoObservatory
  module ObservatoryHelper
    # deprecated
    def observatory_map_enabled?
      current_site.gobierto_observatory_settings &&
        current_site.gobierto_observatory_settings.settings &&
        settings.dig("enabled")
    end

    def gobierto_observatory_js_app_settings
      if settings
        %(
           data-ine-code="#{current_site.organization_id}"
           data-map-lat="#{settings.dig("options", "center", "lat")}"
           data-map-lon="#{settings.dig("options", "center", "lon")}"
           data-endpoint-studies="#{settings.dig("options", "studies_dataset_url")}"
           data-endpoint-origin="#{settings.dig("options", "origin_dataset_url")}"
           data-endpoint-sections="#{settings.dig("options", "sections_dataset_url")}"
        ).html_safe
      end
    end

    private

    def settings
      @settings ||= current_site.gobierto_observatory_settings.settings.dig("observatory_config", "observatory", "map")
    end

  end
end
