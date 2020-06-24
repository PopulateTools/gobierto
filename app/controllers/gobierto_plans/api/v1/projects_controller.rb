# frozen_string_literal: true

module GobiertoPlans
  module Api
    module V1
      class ProjectsController < BaseController
        include ::GobiertoCommon::CustomFieldsApi

        # GET /api/v1/plans/1/projects
        # GET /api/v1/plans/1/projects.json
        def index
          render json: filtered_relation, links: links(:index), each_serializer: GobiertoPlans::NodeSerializer, plan: @plan, adapter: :json_api
        end

        private

        def base_relation
          find_plan

          @plan.nodes.published
        end

        def find_plan
          @plan = current_site.plans.send(valid_preview_token? ? :itself : :published).find_by(id: params[:plan_id])
        end

        def links(self_key = nil)
          {
            index: gobierto_plans_api_v1_plan_projects_path(filter: filter_params)
          }.tap do |hash|
            hash[:self] = hash.delete(self_key) if self_key.present?
          end
        end
      end
    end
  end
end
