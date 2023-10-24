# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  module Api
    module V1
      class ProjectsControllerTest < GobiertoControllerTest
        def site
          @site ||= sites(:madrid)
        end

        def admin_token
          @admin_token ||= "Bearer #{gobierto_admin_api_tokens(:natasha_primary_api_token).token}"
        end

        def user_token
          @user_token ||= "Bearer #{user_api_tokens(:peter_primary_api_token).token}"
        end

        def plan
          @other_plan ||= gobierto_plans_plans(:strategic_plan)
        end

        def published_project
          @published_project ||= gobierto_plans_nodes(:political_agendas)
        end

        def draft_project
          @draft_project ||= gobierto_plans_nodes(:scholarships_kindergartens)
        end

        def attributes_data(project)
          {
            "category_id": project.categories.first&.id,
            "progress": project.progress,
            "starts_at": project.starts_at&.to_s,
            "ends_at": project.ends_at&.to_s,
            "status_id": project.status_id,
            "position": project.position,
            "external_id": project.external_id
        }
        end

        def public_attributes_data(project)
          { "name": project.name }.merge(attributes_data(project))
        end

        def admin_attributes_data(project)
          {
            "visibility_level": project.visibility_level,
            "moderation_stage": project.moderation_stage,
            "name_translations": project.name_translations.presence || { "en" => nil, "es" => nil },
            "category_external_id": project.categories.first&.external_id,
            "status_external_id": project.status&.external_id
          }.merge(attributes_data(project))
        end

        def invalid_params
          {
            data:
            {
              type: "gobierto_plans-nodes",
              attributes:
              {
                "name_translations": nil
              }
            }
          }
        end

        def valid_params
          {
            data:
            {
              type: "gobierto_plans-nodes",
              attributes:
              {
                "external_id": "from_api",
                "visibility_level": "published",
                "moderation_stage": "approved",
                "name_translations": {
                  "es": "Proyectaco",
                  "en": "Big project"
                },
                "category_external_id": "4",
                "status_external_id": "2",
                "progress": 14.0,
                "starts_at": "2023-09-26",
                "ends_at": "2030-01-01"
              }
            }
          }
        end

        def update_valid_params
          {
            data:
            {
              type: "gobierto_plans-nodes",
              attributes:
              {
                "visibility_level": "published",
                "moderation_stage": "approved",
                "name_translations": {
                  "en": "Publish political agendas UPDATED",
                  "es": "Publicar agendas políticas UPDATED"
                },
                "category_external_id": "4",
                "status_external_id": "2",
                "progress": 100.0,
                "starts_at": "2023-09-26",
                "ends_at": "2030-01-01"
              }
            }
          }
        end

        def check_unauthorized
          with(site:) do
            yield

            assert_response :unauthorized
          end
        end

        # GET /api/v1/plans/1/project.json
        def test_index
          with(site:) do
            get gobierto_plans_api_v1_plan_projects_path(plan), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal plan.nodes.published.count, response_data["data"].count
            projects_names = response_data["data"].map { |item| item["attributes"]["name"] }
            assert_includes projects_names, published_project.name
            refute_includes projects_names, draft_project.name
          end
        end

        # GET /api/v1/plans/1/projects/1.json
        def test_show
          with(site:) do
            get gobierto_plans_api_v1_plan_project_path(plan, published_project), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"

            resource_data = response_data["data"]
            assert_equal published_project.id.to_s, resource_data["id"]
            assert_equal "gobierto_plans-nodes", resource_data["type"]

            attributes = public_attributes_data(published_project)

            attributes.each do |attribute, value|
              assert resource_data["attributes"].has_key? attribute.to_s
              assert_equal value, resource_data["attributes"][attribute.to_s]
            end
          end
        end

        # GET /api/v1/vocabularies/1/terms/new.json
        def test_new_without_token
          check_unauthorized { get new_gobierto_plans_api_v1_plan_project_path(plan), as: :json }
        end

        def test_new_with_user_token
          check_unauthorized { get new_gobierto_plans_api_v1_plan_project_path(plan), headers: { Authorization: user_token }, as: :json }
        end

        def test_new_with_admin_token
          with(site:) do
            get new_gobierto_plans_api_v1_plan_project_path(plan), headers: { Authorization: admin_token }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"

            resource_data = response_data["data"]
            assert_equal "gobierto_plans-nodes", resource_data["type"]
            refute response_data.has_key? "id"

            attributes = admin_attributes_data(plan.nodes.new(visibility_level: "published"))

            attributes.each do |attribute, value|
              assert resource_data["attributes"].has_key? attribute.to_s
              assert_equal value, resource_data["attributes"][attribute.to_s]
            end
          end
        end
      end
    end
  end
end
