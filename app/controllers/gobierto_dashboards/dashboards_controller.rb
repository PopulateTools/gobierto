# frozen_string_literal: true

module GobiertoDashboards
  class DashboardsController < GobiertoDashboards::ApplicationController

    before_action :dashboard_enabled!

    def contracts; end
    def subsidies; end

    private

    def dashboard_enabled!
      render_404 unless dashboards_config.fetch('enabled', false)
    end

    def dashboards_config
      @dashboards_config ||= module_settings.dashboards_config.dig('dashboards', action_name)
    end

    def module_settings
      @module_settings ||= ::GobiertoModuleSettings.find_by(site_id: current_site.id, module_name: module_name)
    end

    def module_name
      self.class.module_parent.name.demodulize
    end

  end
end
