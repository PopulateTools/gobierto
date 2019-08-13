# frozen_string_literal: true

require "test_helper"

module GobiertoInvestments
  module Api
    module V1
      class ProjectsControllerTest < GobiertoControllerTest

        attr_reader :default_secret, :token_service

        def setup
          super

          @default_secret = "S3cr3t"
          @token_service = with_stubbed_jwt_default_secret(default_secret) do
            GobiertoCommon::TokenService.new
          end
        end

        def site
          @site ||= sites(:madrid)
        end

        def site_witout_projects_authorizations
          @site_witout_projects_authorizations ||= sites(:santander)
        end

        def project
          @project ||= gobierto_investments_projects(:public_pool_project)
        end

        def project_without_external_id
          @project_without_external_id ||= gobierto_investments_projects(:sports_center_project)
        end

        def manager_admin
          gobierto_admin_admins(:nick)
        end

        def authorized_regular_admin
          gobierto_admin_admins(:tony)
        end

        def unauthorized_regular_admin
          gobierto_admin_admins(:steve)
        end

        def auth_token(admin)
          token_service.encode(sub: "login", api_token: admin.api_token)
        end

        def new_project_data
          @new_project_data ||= {
            "data": {
              "type": "gobierto_investments_projects",
              "attributes": {
                "external_id": "API01",
                "title_translations": {
                  "es": "Proyecto desde API",
                  "en": "Project from API"
                }
              }
            }
          }.with_indifferent_access
        end

        def existing_project_data
          @existing_project_data ||= {
            "data": {
              "type": "gobierto_investments_projects",
              "attributes": {
                "external_id": project.external_id,
                "title_translations": {
                  "es": "Proyecto desde API",
                  "en": "Project from API"
                }
              }
            }
          }.with_indifferent_access
        end

        # Index
        #
        # GET /gobierto_investments/api/v1/projects
        # GET /gobierto_investments/api/v1/projects.json
        def test_index
          with(site: site) do

            get gobierto_investments_api_v1_projects_path, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert_equal 2, response_data["data"].count
            ids = response_data["data"].map { |item| item["id"].to_i }
            assert_includes ids, project.id
            assert_includes ids, project_without_external_id.id
          end
        end

        # Show
        #
        # GET /gobierto_investments/api/v1/projects/1
        # GET /gobierto_investments/api/v1/projects/1.json
        def test_show
          with(site: site) do

            get gobierto_investments_api_v1_project_path(project), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert_equal project.id, response_data["data"]["id"].to_i
            assert_equal project.title, response_data["data"]["attributes"]["title_translations"][I18n.locale.to_s]
            assert_equal project.external_id, response_data["data"]["attributes"]["external_id"]
          end
        end

        # New
        #
        # GET /gobierto_investments/api/v1/projects/new
        # GET /gobierto_investments/api/v1/projects/new.json
        def test_new
          with(site: site) do

            get new_gobierto_investments_api_v1_project_path, as: :json

            assert_response :success

            response_data = response.parsed_body

            refute response_data["data"].has_key? "id"
            assert_nil response_data["data"]["attributes"]["title_translations"]
            assert_nil response_data["data"]["attributes"]["external_id"]
          end
        end

        # Create
        #
        # POST /gobierto_investments/api/v1/projects
        # POST /gobierto_investments/api/v1/projects.json
        def test_create_without_token
          with(site: site) do
            post gobierto_investments_api_v1_projects_path, as: :json

            assert_response :unauthorized
            assert_equal({ "message" => "Unauthorized" }, response.parsed_body)
          end
        end

        def test_create_invalid_token
          with(site: site) do
            with_stubbed_jwt_default_secret(default_secret) do
              auth_header = "Bearer WADUS"

              post(
                gobierto_investments_api_v1_projects_path,
                headers: { "Authorization" => auth_header },
                params: new_project_data,
                as: :json
              )
              assert_response :unauthorized
              assert_equal({ "message" => "Unauthorized" }, response.parsed_body)
            end
          end
        end

        def test_create_with_nil_api_token
          with(site: site) do
            with_stubbed_jwt_default_secret(default_secret) do
              auth_header = "Bearer #{token_service.encode(sub: "login", api_token: nil)}"
              post(
                gobierto_investments_api_v1_projects_path,
                headers: { "Authorization" => auth_header },
                params: new_project_data,
                as: :json
              )
              assert_response :unauthorized
              assert_equal({ "message" => "Unauthorized" }, response.parsed_body)
            end
          end
        end

        def test_create_invalid_default_secret
          with(site: site) do
            with_stubbed_jwt_default_secret(default_secret) do
              @token_service = GobiertoCommon::TokenService.new(secret: "Wadus!")
              auth_header = "Bearer #{ auth_token(authorized_regular_admin) }"

              post(
                gobierto_investments_api_v1_projects_path,
                headers: { "Authorization" => auth_header },
                params: new_project_data,
                as: :json
              )
              assert_response :unauthorized
              assert_equal({ "message" => "Unauthorized" }, response.parsed_body)
            end
          end
        end

        def test_create_regular_admin_unauthorized
          with(site: site) do
            with_stubbed_jwt_default_secret(default_secret) do
              auth_header = "Bearer #{ auth_token(unauthorized_regular_admin) }"

              post(
                gobierto_investments_api_v1_projects_path,
                headers: { "Authorization" => auth_header },
                params: new_project_data,
                as: :json
              )
              assert_response :unauthorized
              assert_equal({ "message" => "Module not allowed" }, response.parsed_body)
            end
          end
        end

        def test_create_regular_admin_authorized
          with(site: site) do
            with_stubbed_jwt_default_secret(default_secret) do
              auth_header = "Bearer #{ auth_token(authorized_regular_admin) }"

              assert_difference "GobiertoInvestments::Project.count", 1 do
                post(
                  gobierto_investments_api_v1_projects_path,
                  headers: { "Authorization" => auth_header },
                  params: new_project_data,
                  as: :json
                )
              end

              assert_response :success

              response_data = response.parsed_body
              assert_equal(
                response_data["data"]["attributes"]["external_id"],
                new_project_data["data"]["attributes"]["external_id"]
              )
              assert response_data["data"]["id"].present?
            end
          end
        end

        def test_create_regular_admin_authorized_with_existing_external_id
          with(site: site) do
            with_stubbed_jwt_default_secret(default_secret) do
              auth_header = "Bearer #{ auth_token(authorized_regular_admin) }"

              assert_difference "GobiertoInvestments::Project.count", 0 do
                post(
                  gobierto_investments_api_v1_projects_path,
                  headers: { "Authorization" => auth_header },
                  params: existing_project_data,
                  as: :json
                )
              end

              assert_response :success

              response_data = response.parsed_body
              assert_equal(
                response_data["data"]["attributes"]["external_id"],
                existing_project_data["data"]["attributes"]["external_id"]
              )
              assert_equal project.id, response_data["data"]["id"].to_i
            end
          end
        end

        def test_create_regular_admin_authorized_without_external_id
          with(site: site) do
            with_stubbed_jwt_default_secret(default_secret) do
              auth_header = "Bearer #{ auth_token(authorized_regular_admin) }"

              existing_project_data["data"]["attributes"].delete("external_id")

              assert_difference "GobiertoInvestments::Project.count", 1 do
                post(
                  gobierto_investments_api_v1_projects_path,
                  headers: { "Authorization" => auth_header },
                  params: existing_project_data,
                  as: :json
                )
              end

              assert_response :success

              last_project = GobiertoInvestments::Project.last
              response_data = response.parsed_body
              assert_nil last_project.external_id
              assert_equal last_project.id, response_data["data"]["id"].to_i
              assert_equal(
                response_data["data"]["attributes"]["title_translations"],
                existing_project_data["data"]["attributes"]["title_translations"]
              )
            end
          end
        end

        def test_create_regular_admin_authorized_on_other_site
          with(site: site_witout_projects_authorizations) do
            with_stubbed_jwt_default_secret(default_secret) do
              auth_header = "Bearer #{ auth_token(authorized_regular_admin) }"

              post(
                gobierto_investments_api_v1_projects_path,
                headers: { "Authorization" => auth_header },
                params: new_project_data,
                as: :json
              )
              assert_response :unauthorized
              assert_equal({ "message" => "Module not allowed" }, response.parsed_body)
            end
          end
        end

        # Update
        #
        # PATCH/PUT /gobierto_investments/api/v1/projects/1
        # PATCH/PUT /gobierto_investments/api/v1/projects/1
        def test_update_admin_authorized
          with(site: site) do
            with_stubbed_jwt_default_secret(default_secret) do
              auth_header = "Bearer #{ auth_token(authorized_regular_admin) }"

              put(
                gobierto_investments_api_v1_project_path(project_without_external_id),
                headers: { "Authorization" => auth_header },
                params: new_project_data,
                as: :json
              )

              assert_response :success

              response_data = response.parsed_body
              project_without_external_id.reload
              assert_equal(
                response_data["data"]["attributes"]["external_id"],
                new_project_data["data"]["attributes"]["external_id"]
              )
              assert_equal(
                response_data["data"]["attributes"]["external_id"],
                project_without_external_id.external_id
              )
              assert response_data["data"]["id"].present?
              assert_equal project_without_external_id.id, response_data["data"]["id"].to_i
            end
          end
        end

        def test_update_admin_unauthorized
          with(site: site) do
            with_stubbed_jwt_default_secret(default_secret) do
              auth_header = "Bearer #{ auth_token(unauthorized_regular_admin) }"

              put(
                gobierto_investments_api_v1_project_path(project_without_external_id),
                headers: { "Authorization" => auth_header },
                params: new_project_data,
                as: :json
              )

              assert_response :unauthorized
              assert_equal({ "message" => "Module not allowed" }, response.parsed_body)
            end
          end
        end

        # Destroy
        #
        # DELETE /gobierto_investments/api/v1/projects/1
        # DELETE /gobierto_investments/api/v1/projects/1.json
        def test_destroy_admin_authorized
          with(site: site) do
            with_stubbed_jwt_default_secret(default_secret) do
              auth_header = "Bearer #{ auth_token(authorized_regular_admin) }"

              project_id = project.id
              assert_difference "GobiertoInvestments::Project.count", -1 do
                delete(
                  gobierto_investments_api_v1_project_path(project),
                  headers: { "Authorization" => auth_header },
                  as: :json
                )
              end

              assert_response :success
              assert(response.parsed_body.blank?)
              refute GobiertoInvestments::Project.where(id: project_id).exists?
            end
          end
        end

        def test_destroy_admin_unauthorized
          with(site: site) do
            with_stubbed_jwt_default_secret(default_secret) do
              auth_header = "Bearer #{ auth_token(unauthorized_regular_admin) }"

              project_id = project.id
              assert_difference "GobiertoInvestments::Project.count", 0 do
                delete(
                  gobierto_investments_api_v1_project_path(project_without_external_id),
                  headers: { "Authorization" => auth_header },
                  as: :json
                )
              end

              assert_response :unauthorized
              assert_equal({ "message" => "Module not allowed" }, response.parsed_body)
              assert GobiertoInvestments::Project.where(id: project_id).exists?
            end
          end
        end

      end
    end
  end
end
