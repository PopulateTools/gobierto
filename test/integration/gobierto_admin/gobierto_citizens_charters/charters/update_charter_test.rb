# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Charters
      class UpdateCharterTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = edit_admin_citizens_charters_charter_path(charter)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def unauthorized_admin
          @unauthorized_admin ||= gobierto_admin_admins(:steve)
        end

        def site
          @site ||= sites(:madrid)
        end

        def charter
          @charter ||= gobierto_citizens_charters_charters(:teleassistance_charter)
        end

        def test_permissions
          with_signed_in_admin(unauthorized_admin) do
            with_current_site(site) do
              visit @path
              assert has_content?("You are not authorized to perform this action")
              assert_equal admin_root_path, current_path
            end
          end
        end

        def test_update_charter
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                fill_in "charter_title_translations_en", with: "Teleassistance charter updated"
                select "Day care service", from: "charter_service_id"

                click_button "Update"

                assert has_message?("The charter has been correctly updated.")

                visit @path

                assert has_field? "charter_title_translations_en", with: "Teleassistance charter updated"
                assert has_select? "charter_service_id", with_selected: "Day care service"
              end
            end
          end

          activity = Activity.last
          assert_equal charter, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_citizens_charters.charter.updated", activity.action
        end

        def test_update_draft_charter
          charter.update_attribute(:visibility_level, :draft)

          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                assert_no_difference "Activity.count" do
                  visit @path

                  fill_in "charter_title_translations_en", with: "Teleassistance charter updated"
                  select "Day care service", from: "charter_service_id"

                  click_button "Update"

                  assert has_message?("The charter has been correctly updated.")

                  visit @path

                  assert has_field? "charter_title_translations_en", with: "Teleassistance charter updated"
                  assert has_select? "charter_service_id", with_selected: "Day care service"
                end
              end
            end
          end
        end

        def test_publish_draft_charter
          charter.update_attribute(:visibility_level, :draft)

          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                within ".widget_save" do
                  find("label", text: "Published").click
                end

                click_button "Update"

                assert has_message?("The charter has been correctly updated.")

                visit @path

                assert has_field? "charter_title_translations_en", with: charter.title_en
                click_link "ES"
                assert has_field? "charter_title_translations_es", with: charter.title_es
              end
            end
          end

          activity = Activity.last
          assert_equal charter, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_citizens_charters.charter.published", activity.action
        end

        def test_update_charter_error
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                fill_in "charter_title_translations_en", with: ""
                click_link "ES"
                fill_in "charter_title_translations_es", with: ""

                click_button "Update"

                assert has_alert?("can't be blank")
              end
            end
          end
        end
      end
    end
  end
end
