# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoInvestments
    module Projects
      class CreateProjectTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = new_admin_investments_project_path
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

        def test_create_project_errors
          with(site: site, admin: admin, js: true) do
            visit @path

            click_button "Create"

            assert has_alert?("Title can't be blank")
          end
        end

        def test_create_project
          with(site: site, admin: admin, js: true) do
            visit @path

            fill_in "project_title_translations_en", with: "Concert hall"

            switch_locale "ES"
            fill_in "project_title_translations_es", with: "Sala de conciertos"

            fill_in "project_external_id", with: "ID002"

            click_button "Create"

            assert has_message?("Project created correctly.")

            assert has_field?("project_title_translations_en", with: "Concert hall")

            switch_locale "ES"

            assert has_field?("project_title_translations_es", with: "Sala de conciertos")
          end

          activity = Activity.last
          new_project = ::GobiertoInvestments::Project.last
          assert_equal new_project, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_investments.project.project_created", activity.action
        end
      end
    end
  end
end
