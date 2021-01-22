# frozen_string_literal: true

module GobiertoAdmin
  module DashboardsHelper
    extend ActiveSupport::Concern

    included do
      attr_reader :base_relation, :context_resource

      before_action { module_enabled!(current_site, "GobiertoDashboards") }
      before_action { module_allowed!(current_admin, "GobiertoDashboards") }
      before_action -> { module_allowed_action!(current_admin, current_admin_module, [:manage_dashboards, :view_dashboards]) }, only: [:index, :show]
      before_action -> { module_allowed_action!(current_admin, current_admin_module, :manage_dashboards) }, only: [:edit, :update, :new, :create, :destroy]
    end

    def index
      @dashboards = base_relation
      @context = context_resource.to_global_id.to_s
    end
  end
end
