# frozen_string_literal: true

module GobiertoVisualizations
  class VisualizationsController < GobiertoVisualizations::ApplicationController

    before_action :visualization_enabled!

    MIN_CONTRACT_ID = 1
    MAX_CONTRACT_ID = 15_000_000

    def contracts
      render_404 and return false if params[:id].present? &&
        (params[:id].to_i < MIN_CONTRACT_ID || params[:id].to_i > MAX_CONTRACT_ID || !params[:id].match?(/\A\d+\z/))
    end
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
