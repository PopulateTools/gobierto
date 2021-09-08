# frozen_string_literal: true

module GobiertoVisualizations
  class VisualizationsController < GobiertoVisualizations::ApplicationController

    before_action :visualization_enabled!

    def contracts; end
    def subsidies; end

    private

    def visualization_enabled!
      render_404 unless visualizations_config&.fetch("enabled", false)
    end

    def visualizations_config
      @visualizations_config ||= module_settings.visualizations_config.dig('visualizations', action_name)
    end

    def module_settings
      @module_settings ||= ::GobiertoModuleSettings.find_by(site_id: current_site.id, module_name: module_name)
    end

    def module_name
      self.class.module_parent.name.demodulize
    end

  end
end
