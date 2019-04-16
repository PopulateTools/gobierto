# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class CategoriesController < GobiertoAdmin::GobiertoCommon::OrderedTermsController
      skip_before_action :check_permissions!

      before_action -> { module_allowed_action!(current_admin, current_admin_module, :manage) }

      helper_method :current_admin_actions

      def index
        find_vocabulary
        calculate_accumulated_values

        @global_progress = @plan.nodes.average(:progress).to_f
        @projects_filter_form = ::GobiertoAdmin::GobiertoPlans::ProjectsFilterForm.new(plan: @plan, admin: current_admin)
        @terms = TreeDecorator.new(tree(@vocabulary.terms), decorator: ::GobiertoPlans::CategoryTermDecorator, options: { plan: @plan })
      end

      def accumulated_values
        find_vocabulary
        calculate_accumulated_values

        render json: @accumulated_values
      end

      private

      def index_path
        admin_plans_plan_categories_path(@plan)
      end

      def find_term
        find_vocabulary
        @term = @vocabulary.terms.find(params[:id])
      end

      def calculate_accumulated_values
        @accumulated_values ||= @vocabulary.terms.inject({}) do |calculations, term|
          decorated_term = ::GobiertoPlans::CategoryTermDecorator.new(term, plan: @plan)

          calculations.update(
            term.id => decorated_term.decorated_values
          )
        end

        @calculated_values_path = accumulated_values_admin_plans_plan_categories_path(@plan)
      end

      def find_vocabulary
        @plan = current_site.plans.find params[:plan_id]
        @vocabulary = @plan.categories_vocabulary
      end

      def raise_action_not_allowed
        find_vocabulary
        redirection_path = current_admin_actions.include?(:index) ? admin_plans_plan_projects_path(@plan) : admin_plans_plan_categories_path(@plan)
        redirect_to(
          redirection_path,
          alert: t("gobierto_admin.module_helper.not_enabled")
        )
      end

      def current_admin_actions
        @current_admin_actions ||= GobiertoAdmin::GobiertoPlans::ProjectPolicy.new(
          current_admin: current_admin,
          current_site: current_site
        ).allowed_actions
      end
    end
  end
end
