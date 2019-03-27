# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class ProjectsController < BaseController
      before_action :find_plan

      def index
        find_plan
        set_filters

        @projects = @relation
      end

      def destroy
        find_plan
        set_filters

        @project = @plan.nodes.find params[:id]
        @project.destroy

        projects_filter = if filter_params.values.any?(&:present?)
                            { projects_filter: filter_params }
                          else
                            {}
                          end

        redirect_to admin_plans_plan_projects_path(@plan, projects_filter), notice: t(".success")
      end

      private

      def set_filters
        @relation = base_relation
        @form = ProjectsFilterForm.new(filter_params.merge(plan: @plan))
        @form.filter_params.each do |param|
          @relation = @relation.send(:"with_#{param}", filter_params[param])
        end
      end

      def find_plan
        @plan = current_site.plans.find params[:plan_id]
      end

      def base_relation
        @plan.nodes
      end

      def filter_params
        return {} unless params.has_key? :projects_filter

        @filter_params ||= params.require(:projects_filter).permit(ProjectsFilterForm::FILTER_PARAMS)
      end
    end
  end
end
