# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    module Projects
      class CreateProjectTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = new_admin_plans_plan_project_path(plan)
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

        def test_regular_admin_without_groups_create_project
          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              assert has_alert? "You are not authorized to perform this action"
            end
          end
        end

        def test_regular_admin_not_editor_create_project
          allow_regular_admin_manage_plans
          allow_regular_admin_moderate_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              assert has_alert? "You are not authorized to perform this action"
            end
          end
        end

        def test_regular_editor_admin_create_invalid_project
          allow_regular_admin_edit_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              click_button "Save"

              assert has_alert? "Category can't be blank"
            end
          end
        end

        def test_regular_editor_admin_create_valid_project
          allow_regular_admin_edit_plans

          with_javascript do
            with_signed_in_admin(regular_admin) do
              with_current_site(site) do
                visit @path

                select "Scholarships for families in the Central District", from: "project_category_id"

                fill_in "project_name_translations_en", with: "New project"
                fill_in "project_status_translations_en", with: "Not started"

                click_link "ES"
                fill_in "project_name_translations_es", with: "Nuevo proyecto"
                fill_in "project_status_translations_es", with: "No iniciado"

                fill_in "project_starts_at", with: "2020-01-01"
                fill_in "project_ends_at", with: "2021-01-01"
                select "1%", from: "project_progress"

                click_button "Save"

                assert has_content? "Project created correctly."

                project = plan.nodes.last
                assert_equal regular_admin, project.author
                assert_equal "New project", project.name
                assert_equal "Not started", project.status
                assert_equal "Nuevo proyecto", project.name_es
                assert_equal "No iniciado", project.status_es
                assert_equal 1.0, project.progress
                assert_equal Date.parse("2020-01-01"), project.starts_at
                assert_equal Date.parse("2021-01-01"), project.ends_at
                assert project.draft?
                assert project.moderation.not_sent?
              end
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
