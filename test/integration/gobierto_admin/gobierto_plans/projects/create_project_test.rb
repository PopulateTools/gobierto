# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/previewable_item_test_module"

module GobiertoAdmin
  module GobiertoPlans
    module Projects
      class CreateProjectTest < ActionDispatch::IntegrationTest
        include Integration::AdminGroupsConcern
        include ::GobiertoAdmin::PreviewableItemTestModule

        def setup
          super

          remove_custom_fields_with_callbacks
          @path = new_admin_plans_plan_project_path(plan)
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

        def remove_custom_fields_with_callbacks
          ::GobiertoCommon::CustomFieldPlugin.with_callbacks.each do |plugin|
            ::GobiertoCommon::CustomField.with_plugin_type(plugin.type).destroy_all
          end
        end

        def preview_test_conf
          {
            item_admin_path: @path,
            item_public_url: gobierto_plans_plan_url(plan.plan_type.slug, plan.year, host: site.domain),
            publish_proc: -> { plan.published! },
            unpublish_proc: -> { plan.draft! }
          }
        end

        def test_regular_admin_without_groups_create_project
          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              assert has_alert? "You are not authorized to perform this action"
            end
          end
        end

        def test_regular_admin_not_creator_create_project
          allow_regular_admin_manage_plans
          allow_regular_admin_moderate_all_projects
          allow_regular_admin_edit_all_projects
          allow_regular_admin_publish_all_projects

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              assert has_alert? "You are not authorized to perform this action"
            end
          end
        end

        def test_regular_admin_not_editor_create_project
          allow_regular_admin_manage_plans
          allow_regular_admin_moderate_all_projects

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              assert has_alert? "You are not authorized to perform this action"
            end
          end
        end


        def test_regular_creator_admin_create_invalid_project
          allow_regular_admin_create_projects

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit @path

              click_button "Save"

              assert has_alert? "Category can't be blank"
            end
          end
        end

        def test_regular_editor_creator_admin_create_valid_project
          allow_regular_admin_create_projects
          # The manage allows admin to manage permissions
          allow_regular_admin_edit_all_projects

          with_javascript do
            with_signed_in_admin(regular_admin) do
              with_current_site(site) do
                visit @path

                select "Scholarships for families in the Central District", from: "project_category_id"

                within "div.globalized_fields", match: :first do
                  fill_in "project_name_translations_en", with: "New project"

                  switch_locale "ES"
                  fill_in "project_name_translations_es", with: "Nuevo proyecto"
                end

                fill_in "project_starts_at", with: "2020-01-01"
                fill_in "project_ends_at", with: "2021-01-01"
                select "Not started", from: "project_status_id"
                select "1%", from: "project_progress"

                click_button "Save"

                assert has_content? "Project created correctly."
                assert has_link? "Permissions"
              end
            end
          end

          project = plan.nodes.last
          assert_equal regular_admin, project.author
          assert_equal "New project", project.name
          assert_equal "Not started", project.status.name
          assert_equal "Nuevo proyecto", project.name_es
          assert_equal 1.0, project.progress
          assert_equal Date.parse("2020-01-01"), project.starts_at
          assert_equal Date.parse("2021-01-01"), project.ends_at
          assert project.draft?
          assert project.moderation.unsent?

          activity = Activity.last
          assert_equal project, activity.subject
          assert_equal plan, activity.recipient
          assert_equal regular_admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_plans.project_created", activity.action
        end

        def test_regular_editor_default_progress_on_create_is_zero
          allow_regular_admin_create_projects

          with_javascript do
            with_signed_in_admin(regular_admin) do
              with_current_site(site) do
                visit @path

                select "Scholarships for families in the Central District", from: "project_category_id"

                fill_in "project_name_translations_en", with: "New project"
                select "Not started", from: "project_status_id"

                click_button "Save"

                assert has_content? "Project created correctly."

                project = plan.nodes.last
                assert_equal 0.0, project.progress
              end
            end
          end
        end
      end
    end
  end
end
