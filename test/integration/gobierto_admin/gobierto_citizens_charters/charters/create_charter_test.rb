# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Charters
      class CreateCharterTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = new_admin_citizens_charters_charter_path
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

        def test_permissions
          with_signed_in_admin(unauthorized_admin) do
            with_current_site(site) do
              visit @path
              assert has_content?("You are not authorized to perform this action")
              assert_equal admin_root_path, current_path
            end
          end
        end

        def test_create_charter_errors
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                click_button "Create"

                assert has_alert?("Title can't be blank")
              end
            end
          end
        end

        def test_create_charter
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                fill_in "charter_title_translations_en", with: "Dependent people"

                click_link "ES"
                fill_in "charter_title_translations_es", with: "Personas dependientes"

                select "Teleassistance", from: "charter_service_id"

                within ".widget_save" do
                  find("label", text: "Published").click
                end

                click_button "Create"

                assert has_message?("The charter has been correctly created.")

                new_charter = ::GobiertoCitizensCharters::Charter.last
                within "#charter-item-#{ new_charter.id }" do
                  find("i.fa-edit").click
                end

                assert has_select?("charter_service_id", with_selected: "Teleassistance")

                assert has_field?("charter_title_translations_en", with: "Dependent people")

                click_link "ES"

                assert has_field?("charter_title_translations_es", with: "Personas dependientes")
              end
            end
          end

          activity = Activity.last
          new_charter = ::GobiertoCitizensCharters::Charter.last
          assert_equal new_charter, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_citizens_charters.charter.created", activity.action
        end
      end
    end
  end
end
