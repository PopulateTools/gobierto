# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    module Projects
      class DeleteProjectTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_plans_plan_projects_path(plan)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def regular_admin
          @regular_admin ||= gobierto_admin_admins(:steve)
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

        def test_regular_admin_without_groups_delete_project
          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              assert has_alert? "You are not authorized to perform this action"
            end
          end
        end

        def test_regular_moderator_admin_delete_project
          allow_regular_admin_moderate_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              within "#project-item-#{project.id}" do
                assert has_no_css? "a[data-method='delete']"
              end
            end
          end
        end

        def test_regular_editor_admin_delete_project
          allow_regular_admin_edit_plans

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

        private

        def allow_regular_admin_manage_plans
          regular_admin.admin_groups << gobierto_admin_admin_groups(:madrid_manage_plans_group)
        end

        def allow_regular_admin_edit_plans
          regular_admin.admin_groups << gobierto_admin_admin_groups(:madrid_edit_plans_group)
        end

        def allow_regular_admin_moderate_plans
          regular_admin.admin_groups << gobierto_admin_admin_groups(:madrid_moderate_plans_group)
        end
      end
    end
  end
end
