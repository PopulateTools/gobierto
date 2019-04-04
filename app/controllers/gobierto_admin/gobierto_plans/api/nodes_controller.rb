# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    module Api
      class NodesController < GobiertoPlans::Api::BaseController
        def index
          @plan = current_site.plans.find params[:plan_id]
          @nodes = @plan.nodes
          render json: @nodes, each_serializer: ::GobiertoAdmin::GobiertoPlans::NodeSerializer, plan: @plan
        end

        def create
          @plan = current_site.plans.find(params[:plan_id])
          @node_form = NodeForm.new(node_params.merge(plan_id: params[:plan_id], category_id: params[category_param], admin: current_admin))

          if @node_form.save
            render json: @node_form.node, serializer: ::GobiertoAdmin::GobiertoPlans::NodeSerializer, plan: @plan
          else
            raise_invalid_response
          end
        end

        def update
          @plan = current_site.plans.find(params[:plan_id])
          @node = find_node
          @node_form = NodeForm.new(node_params.merge(id: params[:id], plan_id: params[:plan_id], category_id: params[category_param], admin: current_admin))

          if @node_form.save
            render json: @node_form.node, serializer: ::GobiertoAdmin::GobiertoPlans::NodeSerializer, plan: @plan
          else
            raise_invalid_response
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
            :options_json,
            :visibility_level,
            name_translations: [*I18n.available_locales],
            status_translations: [*I18n.available_locales]
          )
        end

        def category_param
          @category_param ||= :"level_#{@plan.categories.maximum(:level)}"
        end

        def ignored_node_attributes
          %w(created_at updated_at)
        end

        def check_permissions!
          raise_module_not_allowed unless current_admin.can_edit_plans?
        end

        def raise_invalid_response
          render json: { error: "Invalid record" }, status: 400
        end
      end
    end
  end

end
