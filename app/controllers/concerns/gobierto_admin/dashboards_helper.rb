# frozen_string_literal: true

module GobiertoAdmin
  module DashboardsHelper
    extend ActiveSupport::Concern

    included do
      attr_reader :base_relation, :context_resource

      helper_method :index_path

      before_action -> { module_allowed_action!(current_admin, current_admin_module, [:manage_dashboards, :view_dashboards]) }, only: [:index, :show]
      before_action -> { module_allowed_action!(current_admin, current_admin_module, :manage_dashboards) }, only: [:edit, :update, :new, :create, :destroy]
    end

    def index
      @dashboards = base_relation
    end

    def new
      @dashboard_form = ::GobiertoDashboards::DashboardForm.new(
        site_id: current_site.id,
        admin_id: current_admin.id
      )
      @context = context_resource.to_global_id.to_s
      render("gobierto_admin/gobierto_dashboards/dashboards/new_modal", layout: request.xhr? ? false : "gobierto_admin/layouts/application")
    end
  end
end
