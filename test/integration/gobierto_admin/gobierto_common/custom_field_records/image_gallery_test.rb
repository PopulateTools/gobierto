# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module CustomFieldRecord
      class ImageGallertTest < ActionDispatch::IntegrationTest

        attr_reader :plan, :project, :path

        def setup
          super
          @plan = gobierto_plans_plans(:strategic_plan)
          @project = gobierto_plans_nodes(:political_agendas)

          remove_custom_fields_and_create_gallery

          @path = edit_admin_plans_plan_project_path(plan, project)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def site
          @site ||= sites(:madrid)
        end

        def remove_custom_fields_and_create_gallery
          ::GobiertoCommon::CustomField.destroy_all
          ::GobiertoCommon::CustomField.image.create(
            site: site,
            class_name: "GobiertoPlans::Node",
            name_translations: { en: "Image gallery", es: "Galería de imágenes" },
            uid: "image_gallery",
            options: { configuration: { multiple: true } }
          )
        end

        def test_update_project_as_manager
          with(site: site, admin: admin, js: true) do
            visit path

            within "form" do
              click_link "Add image"
              attach_file "image_gallery", Rails.root.join("test/fixtures/files/sites/logo-madrid.png")
              click_link "Add image"
              attach_file "image_gallery", Rails.root.join("test/fixtures/files/gobierto_people/people/avatar-small.jpg")

              has_css?(".new_item", count: 2)

              within "div.widget_save_v2.editor" do
                click_button "Save"
              end
            end

            assert has_message? "Project updated correctly."

            custom_field_record = ::GobiertoCommon::CustomFieldRecord.find_by(item: project)

            assert_equal 2, custom_field_record.value.count

            within "form" do
              find("[data-index='0'][data-behavior='delete_item']").click
              page.accept_alert

              within "div.widget_save_v2.editor" do
                click_button "Save"
              end
            end

            custom_field_record.reload

            assert_equal 1, custom_field_record.value.count
          end
        end

      end
    end
  end
end
