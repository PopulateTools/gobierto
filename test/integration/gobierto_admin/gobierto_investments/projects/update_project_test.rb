# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoInvestments
    module Projects
      class UpdateProjectTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = edit_admin_investments_project_path(project)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def unauthorized_regular_admin
          @unauthorized_regular_admin ||= gobierto_admin_admins(:steve)
        end

        def authorized_regular_admin
          @authorized_regular_admin ||= gobierto_admin_admins(:tony)
        end

        def site
          @site ||= sites(:madrid)
        end

        def project
          @project ||= gobierto_investments_projects(:public_pool_project)
        end

        def test_regular_admin_permissions_not_authorized
          with(site: site, admin: unauthorized_regular_admin) do
            visit @path
            assert has_content?("You are not authorized to perform this action")
            assert_equal edit_admin_admin_settings_path, current_path
          end
        end

        def test_regular_admin_permissions_authorized
          with(site: site, admin: authorized_regular_admin) do
            visit @path
            assert has_no_content?("You are not authorized to perform this action")
            assert_equal @path, current_path
          end
        end

        def test_update_project
          with(site: site, admin: admin, js: true) do
            visit @path

            fill_in "project_title_translations_en", with: "Public pool updated"

            switch_locale "ES"
            fill_in "project_title_translations_es", with: "Piscina pública actualizada"

            fill_in "project_external_id", with: "ID004"

            click_button "Update"

            assert has_message?("Project updated correctly.")

            visit @path

            assert has_field? "project_title_translations_en", with: "Public pool updated"

            switch_locale "ES"

            assert has_field?("project_title_translations_es", with: "Piscina pública actualizada")
            assert has_field?("project_external_id", with: "ID004")
          end

          activity = Activity.last
          assert_equal project, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_investments.project.project_updated", activity.action
        end

        def test_update_project_error
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                fill_in "project_title_translations_en", with: ""
                switch_locale "ES"
                fill_in "project_title_translations_es", with: ""

                click_button "Update"

                assert has_alert?("can't be blank")
              end
            end
          end
        end

        def test_update_custom_field_updates_project
          with(site: site, admin: admin) do
            visit @path

            assert_changes "project.reload.updated_at" do
              fill_in "project_custom_records_text-code_value", with: "test changed"
              click_button "Update"
              assert has_message?("Project updated correctly.")
            end
          end
        end
      end
    end
  end
end
