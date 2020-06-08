# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    module Projects
      class ProjectVersionsTest < ActionDispatch::IntegrationTest
        include Integration::AdminGroupsConcern

        attr_reader :plan, :create_path

        def setup
          super
          @plan = gobierto_plans_plans(:strategic_plan)
          @create_path = new_admin_plans_plan_project_path(plan)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def site
          @site ||= sites(:madrid)
        end

        def default_test_context
          { site: site, js: true, admin: admin, window_size: :xl }
        end

        # Load project dynamically from database (slower but avoids flaky tests)
        def project
          ::GobiertoPlans::Node.with_name_translation("Project with versions", :en).last
        end

        def create_project
          visit create_path

          within "form" do
            select "Scholarships for families in the Central District", from: "project_category_id"

            fill_in "project_name_translations_en", with: "Project with versions"

            fill_in "project_starts_at", with: "2020-01-01"
            fill_in "project_ends_at", with: "2021-01-01"
            select "Active", from: "project_status_id"

            within "div.widget_save_v2.editor" do
              click_button "Save"
            end
          end
        end

        def all_versions_are_equal(project, versions_number)
          return false unless versions_number == project.versions.count

          ::GobiertoCommon::CustomFieldRecord.where(item: project).each do |record|
            next if record.custom_field.plugin? && %w(progress).include?(record.custom_field.configuration.plugin_type)

            return false unless versions_number == record.versions.count
          end

          true
        end

        def choose_moderation_status(status_text)
          find(".js-admin-widget-save a").click
          find("label", text: status_text).click
          body = find("body", visible: false)
          body.execute_script("this.click()") # lose popover hover so it closes
        end

        def click_publish_button_and_accept_alert
          publish_button = find_button("Publish", visible: false)
          publish_button.execute_script("this.click()")
          page.accept_alert
        end

        def test_create_project_as_manager
          with default_test_context do
            create_project

            assert has_message? "Project created correctly."
            assert has_content? "Project with versions"
            assert has_content? "Editing version\n1"
            assert has_content? "Status\nNot published"
            assert has_content? "Published version\nnot published yet"
            assert has_content? "Click on Publish to make this version publicly visible."
          end

          assert all_versions_are_equal(project, 1)
        end

        def test_create_new_version_as_manager
          new_name = "Project with versions: Version 2"

          with default_test_context do
            create_project

            within "form" do
              fill_in "project_name_translations_en", with: new_name

              within "div.widget_save_v2.editor" do
                click_button "Save"
              end
            end
          end

          updated_project = ::GobiertoPlans::Node.with_name_translation(new_name).last
          assert all_versions_are_equal(updated_project, 2)
        end

        def test_create_new_custom_field_version_as_manager
          with default_test_context do

            create_project

            within "form" do
              select "Not started", from: "project_custom_records_status_value"

              within "div.widget_save_v2.editor" do
                click_button "Save"
              end
            end

          end

          assert all_versions_are_equal(project, 2)
        end

        def test_publish_last_version_as_manager
          with default_test_context do

            create_project

            select "Not started", from: "project_custom_records_status_value"

            choose_moderation_status "Approved"

            click_publish_button_and_accept_alert

            assert has_link? "Unpublish"
            assert has_content? "Editing version\n2"
            assert has_content? "Status\nPublished"
            assert has_content? "Published version\n2"
            assert has_content? "Current version is the published one."

          end

          assert all_versions_are_equal(project, 2)
        end

        def test_publish_old_version
          with default_test_context do

            create_project

            select "Not started", from: "project_custom_records_status_value"

            choose_moderation_status "Approved"

            within "div.widget_save_v2.editor" do
              click_button "Save"
            end

            visit edit_admin_plans_plan_project_path(plan, project, version: 1)

            click_publish_button_and_accept_alert

            assert has_content? "Editing version\n2"
            assert has_content? "Status\nNot published"
            assert has_content? "Published version\n1"
            assert has_content? "Click on Publish to make this version publicly visible."

          end

          assert all_versions_are_equal(project, 2)
        end

        def test_publish_old_version_with_changes
          with default_test_context do

            create_project

            assert has_content?("Editing version\n1")
            assert has_content?("not published yet")

            select "Not started", from: "project_custom_records_status_value"

            choose_moderation_status "Approved"

            within "div.widget_save_v2.editor" do
              click_button "Save"
            end

            assert has_content?("Editing version\n2")
            assert has_content?("not published yet")

            visit edit_admin_plans_plan_project_path(plan, project, version: 1)

            select "Done", from: "project_custom_records_status_value"

            within(".widget_save_v2.editor") { click_button "Save" }

            assert has_content?("Editing version\n3")
            assert has_content?("not published yet")

            click_publish_button_and_accept_alert

            assert has_content? "Editing version\n3"
            assert has_content? "Status\nPublished"
            assert has_content? "Published version\n3"
            assert has_content? "Current version is the published one."

          end

          assert all_versions_are_equal(project, 3)
        end

        def test_save_from_old_version_without_changes
          with default_test_context do

            create_project

            select "Not started", from: "project_custom_records_status_value"

            choose_moderation_status "Approved"

            within "div.widget_save_v2.editor" do
              click_button "Save"
            end

            visit edit_admin_plans_plan_project_path(plan, project, version: 1)

            within "form" do
              within "div.widget_save_v2.editor" do
                click_button "Save"
              end
            end

            assert has_content? "Editing version\n3"
            assert has_content? "Status\nNot published"
            assert has_content? "Published version\nnot published yet"
            assert has_content? "Click on Publish to make this version publicly visible."

          end

          assert all_versions_are_equal(project, 3)
        end

        def test_save_new_version_and_change_status
          with default_test_context do

            create_project

            within "form" do
              select "Not started", from: "project_custom_records_status_value"

              within "div.widget_save_v2.editor" do
                click_button "Save"
              end
            end

            visit edit_admin_plans_plan_project_path(plan, project, version: 1)

            within "form" do
              within "div.widget_save_v2.editor" do
                click_button "Save"
              end
            end

            choose_moderation_status "Approved"

            within "div.widget_save_v2.editor" do
              click_button "Save"
            end

            assert has_content? "Editing version\n3"
            assert has_content? "Status\nNot published"
            assert has_content? "Published version\nnot published yet"
            assert has_content? "Click on Publish to make this version publicly visible."
          end

          assert all_versions_are_equal(project, 3)
        end

        def test_minor_change_is_not_available_creating_project
          with(site: site, admin: admin) do
            visit create_path

            within "form" do
              assert has_no_content? "Minor change"
            end
          end
        end

        def test_minor_change_is_not_available_updating_project_older_version
          with default_test_context do
            create_project

            within "form" do
              select "Not started", from: "project_custom_records_status_value"

              within "div.widget_save_v2.editor" do
                click_button "Save"
              end
            end
            within "form" do
              assert has_content? "Minor change"
            end
            visit edit_admin_plans_plan_project_path(plan, project, version: 1)
            within "form" do
              assert has_no_content? "Minor change"
            end
          end
        end

        def test_minor_change_on_last_version
          with default_test_context do
            create_project

            assert all_versions_are_equal(project, 1)
            assert has_content? "Editing version\n1"

            new_name = "Project with versions: Version 2"

            within "form" do
              fill_in "project_name_translations_en", with: new_name

              within "div.widget_save_v2.editor" do
                find("label", text: "Minor change (does not save version)").click
                click_button "Save"
              end
            end

            updated_project = ::GobiertoPlans::Node.with_name_translation(new_name).last
            assert all_versions_are_equal(updated_project, 1)
            assert has_content? "Editing version\n1"
          end
        end
      end
    end
  end
end
