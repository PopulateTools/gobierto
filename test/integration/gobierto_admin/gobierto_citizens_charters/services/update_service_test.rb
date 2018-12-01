# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Services
      class UpdateServiceTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_citizens_charters_services_path
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

        def service
          @service ||= gobierto_citizens_charters_services(:teleassistance)
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

        def test_update_service
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                click_link service.title

                within "form.edit_service" do
                  fill_in "service_title_translations_en", with: "Teleassistance updated"
                  select "Culture", from: "service_category_id"

                  click_button "Update"
                end

                assert has_message?("The service has been correctly updated.")

                click_link service.title

                assert has_field? "service_title_translations_en", with: "Teleassistance updated"
                assert has_select? "service_category_id", with_selected: "Culture"
              end
            end
          end

          activity = Activity.last
          assert_equal service, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_citizens_charters.service.updated", activity.action
        end

        def test_update_draft_service
          service.update_attribute(:visibility_level, :draft)

          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                assert_no_difference "Activity.count" do
                  visit @path

                  click_link service.title
                  within "form.edit_service" do
                    fill_in "service_title_translations_en", with: "Teleassistance updated"
                    select "Culture", from: "service_category_id"

                    click_button "Update"
                  end

                  assert has_message?("The service has been correctly updated.")

                  click_link service.title

                  assert has_field? "service_title_translations_en", with: "Teleassistance updated"
                  assert has_select? "service_category_id", with_selected: "Culture"
                end
              end
            end
          end
        end

        def test_publish_draft_service
          service.update_attribute(:visibility_level, :draft)

          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                click_link service.title
                within "form.edit_service" do
                  within ".widget_save" do
                    find("label", text: "Published").click
                  end

                  click_button "Update"
                end

                assert has_message?("The service has been correctly updated.")

                click_link service.title

                assert has_field? "service_title_translations_en", with: service.title_en
                click_link "ES"
                assert has_field? "service_title_translations_es", with: service.title_es
              end
            end
          end

          activity = Activity.last
          assert_equal service, activity.subject
          assert_equal admin, activity.author
          assert_equal site.id, activity.site_id
          assert_equal "gobierto_citizens_charters.service.published", activity.action
        end

        def test_update_service_error
          with_javascript do
            with_signed_in_admin(admin) do
              with_current_site(site) do
                visit @path

                click_link service.title

                within "form.edit_service" do
                  fill_in "service_title_translations_en", with: ""
                  click_link "ES"
                  fill_in "service_title_translations_es", with: ""
                  select "Culture", from: "service_category_id"

                  click_button "Update"
                end

                assert has_alert?("Title can't be blank")
              end
            end
          end
        end
      end
    end
  end
end
