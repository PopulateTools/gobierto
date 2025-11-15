# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/previewable_item_test_module"

module GobiertoAdmin
  module GobiertoPlans
    module Projects
      class ProjectsIndexTest < ActionDispatch::IntegrationTest
        include Integration::AdminGroupsConcern
        include ::GobiertoAdmin::PreviewableItemTestModule

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
        alias project_with_half_progress project_with_search_matching_name
        alias project_in_progress_status project_with_search_matching_name

        def project_with_no_search_matching_name
          @project_with_no_search_matching_name ||= gobierto_plans_nodes(:scholarships_kindergartens)
        end
        alias project_with_null_progress project_with_no_search_matching_name
        alias project_active_status project_with_no_search_matching_name

        def preview_test_conf
          {
            item_admin_path: @path,
            item_public_url: gobierto_plans_plan_url(plan.plan_type.slug, plan.year, host: site.domain),
            publish_proc: -> { plan.published! },
            unpublish_proc: -> { plan.draft! }
          }
        end

        def test_admin_projects_index
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "table#projects" do
                plan.nodes.each do |project|
                  assert has_selector?("tr#project-item-#{project.id}")
                  within "tr#project-item-#{project.id}" do
                    assert has_content? project.status.name
                  end
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

        def test_regular_admin_plan_manager_projects_index
          allow_regular_admin_manage_plans

          with(site:, admin: regular_admin, js: true) do
            visit @path
            assert has_content? plan.title

            visit admin_plans_plan_categories_path(plan)
            assert has_css?("div.metric.metric_medium", text: "2\nTotal")
          end
        end

        def test_regular_projects_editor_projects_index
          allow_regular_admin_edit_all_projects

          with_signed_in_admin(regular_admin) do
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

        def test_regular_admin_moderator_or_editor_index
          allow_regular_admin_moderate_all_projects
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

        def test_filter_progress
          allow_regular_admin_edit_plans

          with(site: site, js: true, admin: admin) do
            visit @path

            within ".i_filters" do
              select "0% - 25%", from: "projects_filter_progress"
              # click_button "Filter"
            end

            within "table#projects" do
              assert has_selector?("tr#project-item-#{project_with_null_progress.id}")
              assert has_no_selector?("tr#project-item-#{project_with_half_progress.id}")
            end

            within ".i_filters" do
              select "26% - 50%", from: "projects_filter_progress"
              # click_button "Filter"
            end

            within "table#projects" do
              assert has_no_selector?("tr#project-item-#{project_with_null_progress.id}")
              assert has_selector?("tr#project-item-#{project_with_half_progress.id}")
            end
          end
        end

        def test_filter_status
          allow_regular_admin_edit_plans

          with(site: site, js: true, admin: admin) do
            visit @path

            within ".i_filters" do
              select "Active", from: "projects_filter_status"
            end

            within "table#projects" do
              assert has_selector?("tr#project-item-#{project_active_status.id}")
              assert has_no_selector?("tr#project-item-#{project_in_progress_status.id}")
            end

            within ".i_filters" do
              select "In progress", from: "projects_filter_status"
            end

            within "table#projects" do
              assert has_selector?("tr#project-item-#{project_in_progress_status.id}")
              assert has_no_selector?("tr#project-item-#{project_active_status.id}")
            end
          end
        end

        def test_filter_status_on_plan_without_vocabulary
          plan.update_attribute(:statuses_vocabulary_id, nil)
          allow_regular_admin_edit_plans

          with(site: site, js: true, admin: admin) do
            visit @path

            within ".i_filters" do
              assert has_no_selector?("#projects_filter_status")
            end
          end
        end

        def test_case_insensitive_title_filter_search
          allow_regular_admin_edit_plans
          with(site: site, js: true, admin: admin) do
            visit @path

            within ".i_filters" do
              find_field("projects_filter_name").send_keys "AGENDAS", :enter
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
