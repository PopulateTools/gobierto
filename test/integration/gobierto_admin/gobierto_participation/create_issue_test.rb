require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class CreateIssueTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_participation_issues_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_create_issue_errors
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link "New"
              click_button "Create"

              assert has_alert?("Name can't be blank")
              assert has_alert?("URL can't be blank")
            end
          end
        end
      end

      def test_create_issue
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link "New"

              fill_in "issue_name_translations_en", with: "My theme"
              fill_in "issue_slug_translations_en", with: "new-theme"

              click_link "ES"
              fill_in "issue_name_translations_es", with: "Mi tema"
              fill_in "issue_slug_translations_es", with: "mi-tema"

              click_button "Create"

              assert has_message?("Theme was successfully created.")

              click_link "My theme"

              assert has_field?("issue_name_translations_en", with: "My theme")
              assert has_field?("issue_slug_translations_en", with: "new-theme")

              click_link "ES"

              assert has_field?("issue_name_translations_es", with: "Mi tema")
              assert has_field?("issue_slug_translations_es", with: "mi-tema")

              issue = site.issues.last
              activity = Activity.last
              assert_equal issue, activity.subject
              assert_equal admin, activity.author
              assert_equal site.id, activity.site_id
              assert_equal "gobierto_participation.issue_created", activity.action
            end
          end
        end
      end
    end
  end
end
