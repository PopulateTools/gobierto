# frozen_string_literal: true

require "test_helper"
require "support/concerns/api/api_protection_test"

module GobiertoDashboards
  module Api
    module V1
      class DashboardsControllerTest < GobiertoControllerTest
        include ::Api::ApiProtectionTest

        def setup
          super

          admin_without_write_permissions.admin_groups << view_dashboards_admin_group
          admin_with_write_permissions.admin_groups << manage_dashboards_admin_group

          setup_api_protection_test(
            path: gobierto_dashboards_api_v1_dashboards_path,
            site: site,
            admin: admin,
            token_with_domain: gobierto_admin_api_tokens(:tony_domain),
            token_with_other_domain: gobierto_admin_api_tokens(:tony_other_domain)
          )
        end

        def site
          @site ||= sites(:madrid)
        end

        def user
          @user ||= users(:dennis)
        end

        def view_dashboards_admin_group
          @view_dashboards_admin_group ||= gobierto_admin_admin_groups(:madrid_view_plans_dashboards_group)
        end

        def manage_dashboards_admin_group
          @manage_dashboards_admin_group ||= gobierto_admin_admin_groups(:madrid_manage_plans_dashboards_group)
        end

        def user_auth_header
          @user_auth_header ||= "Bearer #{user_api_tokens(:dennis_primary_api_token)}"
        end

        def admin_auth_header
          @admin_auth_header ||= "Bearer #{admin.primary_api_token}"
        end
        alias admin_with_write_permissions_auth_header admin_auth_header

        def admin_without_write_permissions_auth_header
          @admin_without_write_permissions_auth_header ||= "Bearer #{admin_without_write_permissions.primary_api_token}"
        end

        def admin
          @admin ||= gobierto_admin_admins(:tony)
        end
        alias admin_with_write_permissions admin

        def admin_without_write_permissions
          @admin_without_write_permissions ||= gobierto_admin_admins(:steve)
        end

        def site_with_module_disabled
          @site_with_module_disabled ||= sites(:santander)
        end

        def active_dashboards_count
          @active_dashboards_count ||= site.dashboards.active.count
        end

        def dashboard
          @dashboard ||= gobierto_dashboards_dashboards(:urban_planning)
        end
        alias project_dashboard dashboard

        def other_dashboard
          @other_dashboard ||= gobierto_dashboards_dashboards(:indicators)
        end
        alias plan_dashboard other_dashboard

        def plan
          @plan ||= gobierto_plans_plans(:dashboards_plan)
        end

        def plan_custom_fields_records
          @plan_custom_fields_records ||= site.custom_field_records.where(custom_fields: { instance: plan })
        end

        def project
          @project ||= gobierto_plans_nodes(:dashboard_project)
        end

        def project_custom_fields_records
          @project_custom_fields_records ||= site.custom_field_records.where(item: project)
        end

        def other_project
          @other_project ||= gobierto_plans_nodes(:dashboard_alternative_project)
        end

        def other_project_custom_fields_records
          @other_project_custom_fields_records ||= site.custom_field_records.where(item: other_project)
        end

        def test_index_with_module_disabled
          with(site: site_with_module_disabled) do
            get gobierto_dashboards_api_v1_dashboards_path

            assert_response :forbidden
          end
        end

        def valid_params(except: [], with_custom_attributes: {})
          {
            data:
            {
              type: "gobierto_dashboards-dashboards",
              attributes: valid_attributes.except(*except).merge(with_custom_attributes)
            }
          }
        end

        def valid_attributes
          {
            title_translations: {
              en: "New dashboard",
              es: "Nuevo cuadro de mando"
            },
            visibility_level: "active",
            context: plan.to_global_id.to_s,
            widgets_configuration:
            [
              {
                i: "203888c6-338d-4c82-9053-2e5ce0d80391",
                type: "HTML",
                x: 0,
                y: 0,
                w: 12,
                h: 4,
                raw:
                "<h1>Wadus</h1><p>This is a test</p>"
              },
              {
                i: "768f8ed8-d08a-4048-bc67-b5dadaeb09bd",
                type: "INDICATOR",
                x: 0,
                y: 3,
                w: 6,
                h: 7,
                indicator: "indicator-0",
                subtype: "individual"
              },
              {
                i: "768f8ed8-d08a-4048-bc67-b5dadaeb09bd",
                type: "INDICATOR",
                x: 0,
                y: 3,
                w: 6,
                h: 7,
                indicator: "directory",
                subtype: "individual"
              }
            ]
          }
        end

        # GET /api/v1/dashboards
        def test_index
          with(site: site) do
            get gobierto_dashboards_api_v1_dashboards_path, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal active_dashboards_count, response_data["data"].count
            dashboards_titles = response_data["data"].map { |item| item.dig("attributes", "title") }
            assert_includes dashboards_titles, dashboard.title
            item = response_data["data"][dashboards_titles.index(dashboard.title)]["attributes"]
            %w(title context visibility_level widgets_configuration).each do |attribute|
              assert_equal dashboard.send(attribute), item[attribute]
            end

            # assert response_data.has_key? "links"
            # assert_includes response_data["links"].values, gobierto_dashboards_api_v1_dashboards_path
            # assert_includes response_data["links"].values, meta_gobierto_dashboards_api_v1_dashboards_path
          end
        end

        # GET /api/v1/dashboards?context=Module::Model/ID
        def test_index_with_context
          with(site: site) do
            get gobierto_dashboards_api_v1_dashboards_path, params: { context: "GobiertoPlans::Plan/#{plan.id}" }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal 1, response_data["data"].count
            dashboards_titles = response_data["data"].map { |item| item.dig("attributes", "title") }
            assert_includes dashboards_titles, plan_dashboard.title
          end
        end

        # GET /api/v1/dashboards?context=gobierto/Module::Model/ID
        # GET /api/v1/dashboards?context=gid://gobierto/Module::Model/ID
        def test_index_with_full_global_id_context
          with(site: site) do
            get gobierto_dashboards_api_v1_dashboards_path, params: { context: "gobierto/GobiertoPlans::Node/#{project.id}" }, as: :json
            assert_response :success
            response_data = response.parsed_body

            get gobierto_dashboards_api_v1_dashboards_path, params: { context: "gobierto/GobiertoPlans::Node/#{project.id}" }, as: :json
            assert_response :success
            full_gid_response_data = response.parsed_body

            assert_equal full_gid_response_data, response_data

            assert response_data.has_key? "data"
            assert_equal 1, response_data["data"].count
            dashboards_titles = response_data["data"].map { |item| item.dig("attributes", "title") }
            assert_includes dashboards_titles, project_dashboard.title
          end
        end

        # GET /api/v1/dashboards?context=wadus
        def test_index_with_not_existing_context
          with(site: site) do
            get gobierto_dashboards_api_v1_dashboards_path, params: { context: "wadus" }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal [], response_data["data"]
          end
        end

        # GET /api/v1/dashboards/1
        def test_show
          with(site: site) do
            get gobierto_dashboards_api_v1_dashboard_path(dashboard), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal dashboard.id, response_data["data"]["id"].to_i
            item = response_data["data"]["attributes"]
            %w(title context visibility_level widgets_configuration).each do |attribute|
              assert_equal dashboard.send(attribute), item[attribute]
            end
          end
        end

        # GET /api/v1/dashboards/1/data
        def test_dashboard_data_of_plan_dashboard
          with(site: site) do
            get data_gobierto_dashboards_api_v1_dashboard_path(plan_dashboard), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal plan_dashboard.id, response_data["data"]["id"].to_i
            item_data = response_data["data"]["attributes"]

            plan_custom_fields_record_values = plan_custom_fields_records.map(&:value)
            plan_custom_fields_uids = plan_custom_fields_records.map { |record| record.custom_field.uid }.uniq
            plan_projects = plan.nodes

            item_data["values"].each do |record|
              assert_includes plan_custom_fields_record_values, record["values"]
              assert_includes plan_custom_fields_uids, record["name"]
              assert_includes plan_projects, GlobalID::Locator.locate(record["item"])
            end
          end
        end

        def test_dashboard_data_of_project_dashboard
          with(site: site) do
            get data_gobierto_dashboards_api_v1_dashboard_path(project_dashboard), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            assert_equal project_dashboard.id, response_data["data"]["id"].to_i
            item_data = response_data["data"]["attributes"]

            project_custom_fields_record_values = project_custom_fields_records.map(&:value)
            other_project_custom_fields_record_values = other_project_custom_fields_records.map(&:value)

            item_data["values"].each do |record|
              assert_includes project_custom_fields_record_values, record["values"]
              refute_includes other_project_custom_fields_record_values, record["values"]
              assert_equal project, GlobalID::Locator.locate(record["item"])
            end
          end
        end

        def test_dashboard_data_only_includes_data_related_with_the_context
          with(site: site) do
            plan_dashboard.update_attribute(:widgets_configuration, valid_attributes[:widgets_configuration])

            get data_gobierto_dashboards_api_v1_dashboard_path(plan_dashboard), as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            item_data = response_data["data"]["attributes"]

            plan_projects = plan.nodes

            item_data["values"].each do |record|
              assert_equal "indicator-0", record["name"]
              assert_includes plan_projects, GlobalID::Locator.locate(record["item"])
            end
          end
        end

        def test_permissions_of_admin_actions
          with(site: site) do
            post gobierto_dashboards_api_v1_dashboards_path, params: valid_params
            assert_response :unauthorized

            get new_gobierto_dashboards_api_v1_dashboard_path
            assert_response :unauthorized

            put gobierto_dashboards_api_v1_dashboard_path(dashboard), params: valid_params
            assert_response :unauthorized

            delete gobierto_dashboards_api_v1_dashboard_path(dashboard)
            assert_response :unauthorized

            post gobierto_dashboards_api_v1_dashboards_path, headers: { Authorization: user_auth_header }, params: valid_params
            assert_response :unauthorized

            get new_gobierto_dashboards_api_v1_dashboard_path, headers: { Authorization: user_auth_header }
            assert_response :unauthorized

            put gobierto_dashboards_api_v1_dashboard_path(dashboard), headers: { Authorization: user_auth_header }, params: valid_params
            assert_response :unauthorized

            delete gobierto_dashboards_api_v1_dashboard_path(dashboard), headers: { Authorization: user_auth_header }
            assert_response :unauthorized
          end
        end

        def test_permissions_of_regular_admin_without_write_permissions
          with(site: site) do
            post gobierto_dashboards_api_v1_dashboards_path, headers: { Authorization: admin_without_write_permissions_auth_header }, params: valid_params
            assert_response :unauthorized

            post gobierto_dashboards_api_v1_dashboards_path, headers: { Authorization: admin_with_write_permissions_auth_header }, params: valid_params
            assert_response :created
          end
        end

        # GET /api/v1/dashboards/new
        def test_new
          with(site: site) do
            get new_gobierto_dashboards_api_v1_dashboard_path, headers: { Authorization: admin_auth_header }, as: :json

            assert_response :success

            response_data = response.parsed_body

            assert response_data.has_key? "data"
            item = response_data["data"]["attributes"]
            %w(title context visibility_level widgets_configuration).each do |attribute|
              assert item.has_key?(attribute)
            end
          end
        end

        # POST /api/v1/dashboards
        def test_create_without_context
          with(site: site) do
            assert_no_difference "GobiertoDashboards::Dashboard.count" do
              post gobierto_dashboards_api_v1_dashboards_path, headers: { Authorization: admin_auth_header }, params: valid_params(except: [:context])
              assert_response :unprocessable_entity
              assert_match "not found", response.parsed_body.to_json
            end
          end
        end

        def test_create_with_invalid_context
          with(site: site) do
            assert_no_difference "GobiertoDashboards::Dashboard.count" do
              post(
                gobierto_dashboards_api_v1_dashboards_path,
                headers: { Authorization: admin_auth_header },
                params: valid_params(with_custom_attributes: { context: "GobiertoPlans::Plan/123456" })
              )
              assert_response :unprocessable_entity
              assert_match "not found", response.parsed_body.to_json
            end
          end
        end

        def test_create
          with(site: site) do
            assert_difference "GobiertoDashboards::Dashboard.count", 1 do
              post(
                gobierto_dashboards_api_v1_dashboards_path,
                headers: { Authorization: admin_auth_header },
                params: valid_params
              )
              assert_response :created
            end

            new_dashboard = GobiertoDashboards::Dashboard.last

            assert_equal valid_attributes[:title_translations][:en], new_dashboard.title_en
            assert_equal valid_attributes[:title_translations][:es], new_dashboard.title_es
            assert_equal valid_attributes[:context], new_dashboard.context
            valid_attributes[:widgets_configuration].zip(new_dashboard.widgets_configuration).each do |original_widget, stored_widget|
              assert_equal stored_widget.sort, original_widget.deep_stringify_keys.sort
            end
            assert new_dashboard.active?
          end
        end

        def test_create_with_incomplete_valid_gid
          with(site: site) do
            assert_difference "GobiertoDashboards::Dashboard.count", 1 do
              post(
                gobierto_dashboards_api_v1_dashboards_path,
                headers: { Authorization: admin_auth_header },
                params: valid_params(with_custom_attributes: { context: "GobiertoPlans::Plan/#{plan.id}" })
              )
              assert_response :created
            end
          end
        end

        # PUT/PATCH /api/v1/dashboards/1
        def test_update
          with(site: site) do
            put gobierto_dashboards_api_v1_dashboard_path(dashboard), headers: { Authorization: admin_auth_header }, params: valid_params

            dashboard.reload
            assert_equal valid_attributes[:title_translations][:en], dashboard.title_en
            assert_equal valid_attributes[:title_translations][:es], dashboard.title_es
            assert_equal valid_attributes[:context], dashboard.context
            valid_attributes[:widgets_configuration].zip(dashboard.widgets_configuration).each do |original_widget, stored_widget|
              assert_equal stored_widget.sort, original_widget.deep_stringify_keys.sort
            end
            assert dashboard.active?
          end
        end

        def test_destroy
          id = dashboard.id

          assert_difference "GobiertoDashboards::Dashboard.count", -1 do
            with(site: site) do
              delete gobierto_dashboards_api_v1_dashboard_path(id), headers: { Authorization: admin_auth_header }
              assert_response :no_content
            end

            refute GobiertoDashboards::Dashboard.where(id: id).exists?
          end
        end
      end
    end
  end
end
