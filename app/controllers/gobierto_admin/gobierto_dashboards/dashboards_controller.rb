# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoDashboards
    class DashboardsController < GobiertoAdmin::BaseController
      layout false
      helper_method :index_path

      def index
        @context = "context"
      end

      def show
        # dashboard ID/context example
        find_dashboard
      end

      def edit
        find_dashboard
      end

      def create
        @dashboard_form = ::GobiertoDashboards::DashboardForm.new(dashboard_params.merge(site_id: current_site.id))

        if @dashboard_form.save
          redirect_to(
            index_path,
            notice: t(".success")
          )
        else
          @context = dashboard_params[:context]
          render("gobierto_admin/gobierto_dashboards/dashboards/new_modal", layout: "gobierto_admin/layouts/application")
        end
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
