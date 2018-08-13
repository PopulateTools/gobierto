# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    module Api
      class NodesController < BaseController
        def index
          @plan = current_site.plans.find params[:plan_id]
          @nodes = @plan.nodes
          render json: @nodes, plan: @plan
        end

        def create
          @plan = current_site.plans.find(params[:plan_id])
          @node_form = NodeForm.new(node_params.merge(plan_id: params[:plan_id]))

          if @node_form.save
            render json: @node_form.node, plan: @plan
          else
            return_400(@node_form)
          end
        end

        def update
          @node = find_node
          @node_form = NodeForm.new(node_params.merge(id: params[:id], plan_id: params[:plan_id]))

          if @node_form.save
            render json: @node_form.node, plan: @plan
          else
            return_400(@node_form)
          end
        end

        def destroy
          @node = find_node

          if @node.destroy
            render json: { message: "destroyed" }
          else
            render json: { error: "Record couldn't be destroyed" }, status: 400
          end
        end

        private

        def find_node
          ::GobiertoPlans::Node.find(params[:id])
        end

        def node_params
          params.permit(
            :category_id,
            :progress,
            :starts_at,
            :ends_at,
            :options,
            name_translations: [*I18n.available_locales],
            status_translations: [*I18n.available_locales]
          )
        end

        def ignored_node_attributes
          %w(created_at updated_at)
        end

        def check_permissions!
          raise_module_not_allowed unless current_admin.can_edit_plans?
        end
      end
    end
  end

end
