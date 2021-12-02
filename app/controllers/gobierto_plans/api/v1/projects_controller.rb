# frozen_string_literal: true

module GobiertoPlans
  module Api
    module V1
      class ProjectsController < BaseController
        include ::GobiertoCommon::CustomFieldsApi

        # GET /api/v1/plans/1/projects
        # GET /api/v1/plans/1/projects.json
        def index
          json = cache_service.fetch("#{filtered_relation.cache_key_with_version}/#{@plan.cache_key}/#{I18n.locale}/projects_collection") do
            render_to_string(
              json: filtered_relation,
              links: links(:index),
              each_serializer: GobiertoPlans::NodeSerializer,
              plan: @plan,
              custom_fields: custom_fields,
              preloaded_data: transformed_custom_field_record_values(filtered_relation),
              versions_indexes: filtered_relation.versions_indexes,
              category_ids: category_ids,
              adapter: :json_api
            )
          end
          render json: json
        end

        private

        def base_relation
          find_plan

          @plan.nodes.published
        end

        def category_ids
          filtered_relation.select("gplan_nodes.id", "gplan_categories_nodes.category_id").map { |project| [project.id, project.category_id] }.to_h
        end

        def custom_fields
          @custom_fields ||= @plan.front_available_custom_fields
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
