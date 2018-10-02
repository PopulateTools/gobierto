# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    module Api
      class NodesTest < ActionDispatch::IntegrationTest

        def site
          @site ||= sites(:madrid)
        end

        def regular_admin
          @regular_admin ||= gobierto_admin_admins(:steve)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def plan
          @plan ||= gobierto_plans_plans(:strategic_plan)
        end

        def node
          @node ||= gobierto_plans_nodes(:political_agendas)
        end

        def category_term
          @category_term ||= gobierto_common_terms(:center_basic_needs_plan_term)
        end

        def valid_new_node_params
          @valid_new_node_params ||= {
            "name_translations" => { "es" => "Nuevo nodo", "en" => "New node" },
            "status_translations" => { "es" => "Activo", "en" => "Active" },
            "progress" => 50,
            "starts_at" => "2010-01-01",
            "ends_at" => "2020-01-01",
            "options_json" => '{ "Type": "project", "TimePeriod": "Anual" }',
            "level_2" => category_term.id
          }
        end

        def invalid_new_node_params
          @invalid_new_node_params ||= {
            "status_translations" => { "es" => "Activo", "en" => "Active" },
            "progress" => 50,
            "starts_at" => "2010-01-01",
            "ends_at" => "2020-01-01",
            "options" => { "Type" => "project", "TimePeriod" => "Anual" }
          }
        end

        def test_permissions_not_signed_in
          with_current_site(site) do
            visit admin_plans_api_plan_nodes_path(plan)

            assert has_message? "We need you to sign in to continue"
          end
        end

        def test_permissions_regular_admin
          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit admin_plans_api_plan_nodes_path(plan)

              assert has_message? "You are not authorized to perform this action"
            end
          end
        end

        def test_permissions_admin
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit admin_plans_api_plan_nodes_path(plan)

              assert has_content? node.name
            end
          end
        end

        def test_index
          with_current_site(site) do
            login_admin_for_api(admin)

            get admin_plans_api_plan_nodes_path(plan)

            assert_response :success
            response_data = JSON.parse response.body
            assert_equal plan.nodes.count, response_data.count
          end
        end

        def test_create
          with_current_site(site) do
            login_admin_for_api(admin)

            post admin_plans_api_plan_nodes_path(plan), params: valid_new_node_params

            assert_response :success
            response_data = JSON.parse response.body
            assert_equal valid_new_node_params["name_translations"], response_data["name_translations"]

            node = ::GobiertoPlans::Node.find(response_data["id"])
            assert_equal valid_new_node_params["progress"], node.progress
            assert_equal JSON.parse(valid_new_node_params["options_json"]), node.options
            assert_equal category_term, node.categories.first
          end
        end

        def test_invalid_create
          with_current_site(site) do
            login_admin_for_api(admin)

            post admin_plans_api_plan_nodes_path(plan), params: invalid_new_node_params

            assert_response :bad_request
            response_data = JSON.parse response.body
            assert_equal "Invalid record", response_data["error"]
          end
        end

        def test_update
          with_current_site(site) do
            login_admin_for_api(admin)

            put admin_plans_api_plan_node_path(plan, node), params: { "name_translations" => { "es" => "Nombre actualizado", "en" => "Updated name" } }

            assert_response :success
            node.reload
            assert_equal node.name, "Updated name"
          end
        end

        def test_delete
          with_current_site(site) do
            login_admin_for_api(admin)

            delete admin_plans_api_plan_node_path(plan, node), params: { "name_translations" => { "es" => "Nombre actualizado", "en" => "Updated name" } }

            assert_response :success
            assert_empty plan.nodes.where(id: node.id)
          end
        end

      end
    end
  end
end
