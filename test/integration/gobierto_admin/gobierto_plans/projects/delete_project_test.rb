# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/previewable_item_test_module"

module GobiertoAdmin
  module GobiertoPlans
    module Projects
      class DeleteProjectTest < ActionDispatch::IntegrationTest
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

        def project
          @project ||= gobierto_plans_nodes(:political_agendas)
        end

        def preview_test_conf
          {
            item_admin_path: @path,
            item_public_url: gobierto_plans_plan_url(plan.plan_type.slug, plan.year, host: site.domain),
            publish_proc: -> { plan.published! },
            unpublish_proc: -> { plan.draft! }
          }
        end

        def test_regular_admin_without_groups_delete_project
          with(site: site, admin: regular_admin) do
            visit @path

            assert has_alert? "You are not authorized to perform this action"
          end
        end

        def test_regular_moderator_admin_delete_project
          allow_regular_admin_moderate_all_projects

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              within "#project-item-#{project.id}" do
                assert has_no_css? "a[data-method='delete']"
              end
            end
          end
        end

        def test_regular_editor_admin_delete_project_with_empty_author
          allow_regular_admin_edit_plans
          allow_regular_admin_edit_project(project)

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              within "#project-item-#{project.id}" do
                find("a[data-method='delete']").click
              end

              assert has_content? "Project deleted correctly."

              activity = Activity.last
              assert_equal plan, activity.subject
              assert_equal regular_admin, activity.author
              assert_equal site.id, activity.site_id
              assert_equal "gobierto_plans.project_destroyed", activity.action
            end
          end
        end

        def test_regular_editor_admin_delete_other_author_project
          allow_regular_admin_edit_plans
          allow_regular_admin_edit_project(project)
          project.update(admin_id: admin.id)

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              within "#project-item-#{project.id}" do
                assert has_no_css? "a[data-method='delete']"
              end
            end
          end
        end

        def test_regular_editor_admin_delete_own_project
          allow_regular_admin_edit_plans
          project.update(admin_id: regular_admin.id)
          allow_regular_admin_edit_project(project)

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              within "#project-item-#{project.id}" do
                find("a[data-method='delete']").click
              end

              assert has_content? "Project deleted correctly."

            end
          end
        end

        def test_manager_delete_project
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#project-item-#{project.id}" do
                find("a[data-method='delete']").click
              end

              assert has_content? "Project deleted correctly."
            end
          end
        end
      end
    end
  end
end
