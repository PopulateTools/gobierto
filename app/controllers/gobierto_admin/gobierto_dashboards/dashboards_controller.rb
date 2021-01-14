# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoDashboards
    class DashboardsController < GobiertoAdmin::BaseController
      layout false
      helper_method :index_path

      def modal

      end

      private

      def find_dashboard
        @dashboard = current_site.dashboards.find(params[:id])
      end

      def dashboard_params
        params.require(:dashboard).permit(:visibility_level, :context, title_translations: [*I18n.available_locales])
      end

      def index_path
        params.require(:index_path)
      end
    end
  end
end
