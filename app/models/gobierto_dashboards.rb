# frozen_string_literal: true

module GobiertoDashboards
  def self.root_path(current_site)
    Rails.application.routes.url_helpers.gobierto_dashboards_root_path
  end
end
