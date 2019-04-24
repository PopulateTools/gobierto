# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    module Projects
      class UpdateProjectTest < ActionDispatch::IntegrationTest
        attr_reader :plan, :published_project, :unpublished_project, :path, :unpublished_path

        def setup
          super
          @plan = gobierto_plans_plans(:strategic_plan)
          @published_project = gobierto_plans_nodes(:political_agendas)
          @unpublished_project = gobierto_plans_nodes(:scholarships_kindergartens)
          @path = edit_admin_plans_plan_project_path(plan, published_project)
          @unpublished_path = edit_admin_plans_plan_project_path(plan, unpublished_project)
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

        def test_update_project_as_manager
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit path

              within "form" do
                fill_in "project_name_translations_en", with: "Updated project"
                fill_in "project_status_translations_en", with: "Not started"

                fill_in "project_starts_at", with: "2020-01-01"
                fill_in "project_ends_at", with: "2021-01-01"
                select "3%", from: "project_progress"

                within "div.widget_save_v2.editor" do
                  click_button "Save"
                end
              end

              assert has_message? "Project updated correctly."
              assert has_content? "Updated project"

              published_project.reload

              assert_equal "Updated project", published_project.name
              assert_equal "Not started", published_project.status
              assert_equal 3.0, published_project.progress
              assert_equal Date.parse("2020-01-01"), published_project.starts_at
              assert_equal Date.parse("2021-01-01"), published_project.ends_at
              assert published_project.published?
              assert published_project.moderation.approved?
            end
          end
        end

        def test_edit_project_as_regular_moderator
          allow_regular_admin_moderate_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit path

              within "form" do
                assert has_field?("project_name_translations_en", disabled: true)
                assert has_field?("project_status_translations_en", disabled: true)
                assert has_field?("project_starts_at", disabled: true)
                assert has_field?("project_ends_at", disabled: true)
                assert has_field?("project_progress", disabled: true)

                within "div.widget_save_v2.editor" do
                  assert has_no_button? "Save"
                end

                within "div.widget_save_v2.moderator" do
                  assert has_checked_field?("Approved")
                  assert has_button? "Save"
                  assert has_button? "Unpublish"
                end
              end
            end
          end
        end

        def test_unpublish_project_as_regular_moderator
          allow_regular_admin_moderate_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit path

              within "div.widget_save_v2.moderator" do
                click_button "Unpublish"
              end

              assert has_message? "Project updated correctly."

              published_project.reload

              refute published_project.published?
              assert published_project.moderation.approved?
            end
          end
        end

        def test_unpublish_and_change_moderation_stage_of_project_as_regular_moderator
          allow_regular_admin_moderate_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit unpublished_path

              within "div.widget_save_v2.moderator" do
                choose "Under review"
                click_button "Publish"
              end

              assert has_message? "The project is not approved but still published"

              assert has_link? "Unpublish"
              unpublished_project.reload

              assert unpublished_project.published?
              assert unpublished_project.moderation.in_review?
            end
          end
        end

        def test_edit_project_as_regular_manager
          allow_regular_admin_manage_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit path
              assert has_message? "You are not authorized to perform this action"
            end
          end
        end

        def test_edit_project_as_regular_editor
          allow_regular_admin_edit_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit path

              within "form" do
                fill_in "project_name_translations_en", with: "Updated project"
                fill_in "project_status_translations_en", with: "Not started"

                fill_in "project_starts_at", with: "2020-01-01"
                fill_in "project_ends_at", with: "2021-01-01"
                select "3%", from: "project_progress"

                assert has_no_css? "div.widget_save_v2.moderator"
                within "div.widget_save_v2.editor" do
                  click_button "Save"
                end
              end

              assert has_message? "Project updated correctly."
              assert has_content? "Updated project"

              published_project.reload

              assert_equal "Updated project", published_project.name
              assert_equal "Not started", published_project.status
              assert_equal 3.0, published_project.progress
              assert_equal Date.parse("2020-01-01"), published_project.starts_at
              assert_equal Date.parse("2021-01-01"), published_project.ends_at
              assert published_project.published?
              assert published_project.moderation.approved?
            end
          end
        end

        def test_edit_not_approved_project_as_regular_editor
          allow_regular_admin_edit_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit unpublished_path

              within "form" do
                fill_in "project_name_translations_en", with: "Updated project"
                fill_in "project_status_translations_en", with: "Not started"

                fill_in "project_starts_at", with: "2020-01-01"
                fill_in "project_ends_at", with: "2021-01-01"
                select "3%", from: "project_progress"

                assert has_no_css? "div.widget_save_v2.moderator"
                within "div.widget_save_v2.editor" do
                  click_button "Save"
                end
              end

              assert has_message? "Project updated correctly."
              assert has_content? "Updated project"

              unpublished_project.reload

              assert_equal "Updated project", unpublished_project.name
              assert_equal "Not started", unpublished_project.status
              assert_equal 3.0, unpublished_project.progress
              assert_equal Date.parse("2020-01-01"), unpublished_project.starts_at
              assert_equal Date.parse("2021-01-01"), unpublished_project.ends_at
              assert unpublished_project.draft?
              assert unpublished_project.moderation.sent?
            end
          end
        end

        def test_unpublish_approved_project_as_regular_editor
          allow_regular_admin_edit_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit path

              within "div.widget_save_v2.editor" do
                click_button "Unpublish"
              end

              assert has_message? "Project updated correctly."

              published_project.reload

              assert published_project.draft?
              assert published_project.moderation.approved?
            end
          end
        end

        def test_publish_not_approved_project_as_regular_editor
          allow_regular_admin_edit_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit unpublished_path

              within "div.widget_save_v2.editor" do
                assert has_button?("Publish", disabled: true)
              end
            end
          end
        end

        def test_send_project_as_regular_editor
          allow_regular_admin_edit_plans
          unpublished_project.moderation.not_sent!

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit unpublished_path

              within "div.widget_save_v2.editor" do
                click_button "Send"
              end

              within "div.widget_save_v2.editor" do
                assert has_button?("Publish", disabled: true)
              end

              assert has_message? "Project updated correctly."

              unpublished_project.reload

              assert unpublished_project.draft?
              assert unpublished_project.moderation.sent?
            end
          end
        end

        def test_edit_project_as_regular_editor_and_moderator
          allow_regular_admin_edit_plans
          allow_regular_admin_moderate_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit unpublished_path

              within "form" do
                fill_in "project_name_translations_en", with: "Updated project"
                fill_in "project_status_translations_en", with: "Not started"

                fill_in "project_starts_at", with: "2020-01-01"
                fill_in "project_ends_at", with: "2021-01-01"
                select "3%", from: "project_progress"

                assert has_css? "div.widget_save_v2.moderator"
                within "div.widget_save_v2.editor" do
                  click_button "Save"
                end
              end

              assert has_message? "Project updated correctly."
              assert has_content? "Updated project"

              unpublished_project.reload

              assert_equal "Updated project", unpublished_project.name
              assert_equal "Not started", unpublished_project.status
              assert_equal 3.0, unpublished_project.progress
              assert_equal Date.parse("2020-01-01"), unpublished_project.starts_at
              assert_equal Date.parse("2021-01-01"), unpublished_project.ends_at
              assert unpublished_project.draft?
              assert unpublished_project.moderation.sent?
            end
          end
        end

        def test__moderate_project_as_regular_editor_and_moderator
          allow_regular_admin_edit_plans
          allow_regular_admin_moderate_plans

          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              visit unpublished_path

              within "form" do
                within "div.widget_save_v2.moderator" do
                  choose "Under review"
                  click_button "Save"
                end
              end

              assert has_message? "Project updated correctly."

              unpublished_project.reload

              assert unpublished_project.draft?
              assert unpublished_project.moderation.in_review?

              within "form" do
                within "div.widget_save_v2.moderator" do
                  choose "Rejected"
                  click_button "Publish"
                end
              end

              assert has_message? "The project is not approved but still published"
              assert has_link? "Unpublish"

              unpublished_project.reload

              assert unpublished_project.published?
              assert unpublished_project.moderation.rejected?
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
