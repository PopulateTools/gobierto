# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class CategoriesController < GobiertoAdmin::GobiertoCommon::OrderedTermsController
      before_action -> { review_allowed_actions! }
      before_action :set_leaf_terms
      after_action :expire_plan_cache, only: [:update]

      helper_method :current_controller_allowed_actions, :admin_projects_actions

      def index
        find_vocabulary
        unless @vocabulary.present?
          redirect_to edit_admin_plans_plan_path(plan)
          return
        end

        calculate_accumulated_values

        @global_progress = plan.global_progress
        @projects_filter_form = ::GobiertoAdmin::GobiertoPlans::ProjectsFilterForm.new(plan:, admin: current_admin, permissions_policy:, index_all_projects: true)
        @terms = TreeDecorator.new(tree(@vocabulary.terms), decorator: ::GobiertoPlans::CategoryTermDecorator, options: { plan:, vocabulary: @vocabulary, site: current_site })
      end

      def accumulated_values
        find_vocabulary
        calculate_accumulated_values

        render json: @accumulated_values
      end

      private

      def index_path
        admin_plans_plan_categories_path(plan)
      end

      def find_term
        find_vocabulary
        @term = @vocabulary.terms.find(params[:id])
      end

      def calculate_accumulated_values
        @accumulated_values ||= @vocabulary.terms.inject({}) do |calculations, term|
          decorated_term = ::GobiertoPlans::CategoryTermDecorator.new(term, plan:, vocabulary: @vocabulary, site: current_site)

          calculations.update(
            term.id => decorated_term.decorated_values
          )
        end

        @calculated_values_path = accumulated_values_admin_plans_plan_categories_path(plan)
      end

      def find_vocabulary
        @preview_item_url = gobierto_plans_plan_type_preview_url(plan, host: current_site.domain)
        @vocabulary = plan.categories_vocabulary
      end

      def plan
        @plan ||= current_site.plans.find params[:plan_id]
      end

      def current_controller_allowed_actions
        @current_controller_allowed_actions ||= admin_projects_actions&.dig(:collection, :controller_actions) || []
      end

      def permissions_policy
        @permissions_policy ||= GobiertoAdmin::GobiertoPlans::ProjectPolicy.new(
          current_admin: current_admin,
          current_site: current_site,
          plan:
        )
      end

      def gobierto_plans_plan_type_preview_url(plan, options = {})
        if plan.draft?
          options.merge!(preview_token: current_admin.preview_token)
        end
        gobierto_plans_plan_url(plan.plan_type.slug, plan.year, options)
      end

      def expire_plan_cache
        term = current_site.terms.find(params[:id])
        vocabulary = term.vocabulary
        current_site.plans.where(vocabulary_id: vocabulary.id).or(current_site.plans.where(statuses_vocabulary_id: vocabulary.id)).each(&:touch)
      end

      def set_leaf_terms
        if params[:id]
          find_term
          @leaf_terms = leaf_terms_for_select(@vocabulary.terms)
        end
      end

      def leaf_terms_for_select(relation)
        max_level = relation.pluck(:level).max
        if @term.level == max_level
          relation.where("level <> ?", @term.level - 1).pluck(:id)
        else
          relation.where("level >= ?", @term.level).pluck(:id)
        end
      end

      private

      def review_allowed_actions!
        raise_action_not_allowed unless current_controller_allowed_actions.include?(:index)
      end

      def admin_projects_actions
        @admin_projects_actions ||= admin_actions_manager.admin_actions(admin: current_admin, resource: plan.nodes) if plan
      end

      def raise_action_not_allowed
        redirect_to(
          admin_plans_plans_path,
          alert: t("gobierto_admin.module_helper.not_enabled")
        )
      end
    end
  end
end
