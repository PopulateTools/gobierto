# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    module Projects
      class ProjectsIndexTest < ActionDispatch::IntegrationTest
        include Integration::AdminGroupsConcern

        def setup
          super
          @path = admin_plans_plan_projects_path(plan)
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

        def project_with_search_matching_name
          @project_with_search_matching_name ||= gobierto_plans_nodes(:political_agendas)
        end

        def project_with_no_search_matching_name
          @project_with_no_search_matching_name ||= gobierto_plans_nodes(:scholarships_kindergartens)
        end

        def test_admin_projects_index
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "table#projects" do
                plan.nodes.each do |project|
                  assert has_selector?("tr#project-item-#{project.id}")
                end
              end
            end
          end
        end

        def test_regular_admin_without_groups_projects_index
          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              assert has_alert? "You are not authorized to perform this action"
            end
          end
        end

        def test_regular_manager_projects_index
          allow_regular_admin_manage_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              assert has_alert? "You are not authorized to perform this action"
            end
          end
        end

        def test_regular_admin_moderator_or_editor_index
          allow_regular_admin_moderate_plans
          allow_regular_admin_edit_plans

          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "table#projects" do
                plan.nodes.each do |project|
                  assert has_selector?("tr#project-item-#{project.id}")
                end
              end
            end
          end
        end

        def test_case_insensitive_title_filter_search
          allow_regular_admin_edit_plans

          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within ".i_filters" do
                fill_in "projects_filter_name", with: "AGENDAS"
                click_button "Filter"
              end

              within "table#projects" do
                assert has_selector?("tr#project-item-#{project_with_search_matching_name.id}")
                assert has_content?("agendas")
                assert has_no_content?("AGENDAS")
                assert has_no_selector?("tr#project-item-#{project_with_no_search_matching_name.id}")
              end
            end
          end
        end
      end
    end
  end
end
