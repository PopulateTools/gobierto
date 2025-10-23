# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    module Projects
      class ProjectPermissionsTest < ActionDispatch::IntegrationTest
        include Integration::AdminGroupsConcern

        def setup
          super

          @new_path = new_admin_plans_plan_project_path(plan)
          @edit_path = edit_admin_plans_plan_project_path(plan, project)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def site
          @site ||= sites(:madrid)
        end

        def plan
          @plan ||= gobierto_plans_plans(:strategic_plan)
        end

        def project
          @project ||= gobierto_plans_nodes(:political_agendas)
        end

        def permissions_member
          @permissions_member ||= gobierto_admin_admins(:tony)
        end

        def permissions_not_member
          @permissions_not_member ||= gobierto_admin_admins(:steve)
        end

        def select_name(admin)
          "#{admin.name} (#{admin.email})"
        end

        def test_regular_editor_admin_create_valid_project
          allow_regular_admin_edit_plans

          with(site: site, admin: regular_admin, js: true) do
            visit @new_path

            select "Scholarships for families in the Central District", from: "project_category_id"

            within "div.globalized_fields", match: :first do
              fill_in "project_name_translations_en", with: "New project"
            end

            click_button "Save"

            click_link "Permissions"

            within "#modal_index_content" do
              assert has_content? regular_admin.name
              assert has_no_content? "Delete access"
            end
          end
        end

        def test_regular_moderator_admin_adds_admin
          allow_regular_admin_moderate_all_projects

          with(site: site, admin: regular_admin, js: true) do
            visit @edit_path

            click_link "Permissions"

            within "#modal_index_content" do

              within "table" do
                assert has_no_content? permissions_not_member.name
              end

              find("select").select(select_name(permissions_not_member))
              click_button "Add"

              within "table" do
                assert has_content? permissions_not_member.name
              end
            end
          end
        end

        def test_regular_moderator_admin_deletes_admin
          allow_regular_admin_moderate_all_projects

          with(site: site, admin: regular_admin, js: true) do
            visit @edit_path

            click_link "Permissions"

            within "#modal_index_content" do

              within "table" do
                assert has_content? permissions_member.name
              end

              click_link "Delete access"
              page.accept_alert

              within "table" do
                assert has_no_content? permissions_member.name
              end
            end
          end
        end
      end
    end
  end
end
