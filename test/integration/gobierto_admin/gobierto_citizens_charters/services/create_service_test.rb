# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Services
      class CreateServiceTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = new_admin_citizens_charters_service_path
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

        def test_create_service_errors
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                click_button "Create"

                assert has_alert?("can't be blank")
              end
            end
          end
        end

        def test_create_service
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                fill_in "service_title_translations_en", with: "Big service"

                switch_locale "ES"
                fill_in "service_title_translations_es", with: "Gran servicio"

                select "Culture", from: "service_category_id"

                within ".widget_save" do
                  find("label", text: "Published").click
                end

                click_button "Create"

                assert has_message?("The service has been correctly created.")

                click_link "Big service"

                assert has_select?("service_category_id", with_selected: "Culture")

                assert has_field?("service_title_translations_en", with: "Big service")

                switch_locale "ES"

                assert has_field?("service_title_translations_es", with: "Gran servicio")
              end
            end
          end

          activity = Activity.last
          new_service = ::GobiertoCitizensCharters::Service.last
          assert_equal new_service, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_citizens_charters.service.created", activity.action
        end
      end
    end
  end
end
