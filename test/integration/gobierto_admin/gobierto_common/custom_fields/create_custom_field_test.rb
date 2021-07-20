# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module CustomFields
      class CreateCustomFieldTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_common_custom_fields_module_resource_custom_fields_path(module_resource_name: resource_param)
          @instance_level_path = admin_common_custom_fields_module_resource_custom_fields_path(
            module_resource_name: resource_param_with_instance_levels,
            instance_type: resource_instance_type_param,
            instance_id: resource_instance_id
          )
        end

        def resource_class
          @resource_class ||= ::GobiertoInvestments::Project
        end

        def resource_param
          @resource_param ||= resource_class.name.underscore.tr("/", "-")
        end

        def resource_class_with_instance_levels
          @resource_class_with_instance_levels ||= ::GobiertoPlans::Node
        end

        def resource_param_with_instance_levels
          @resource_param_with_instance_levels ||= resource_class_with_instance_levels.name.underscore.tr("/", "-")
        end

        def resource_instance
          gobierto_plans_plans(:strategic_plan)
        end

        def resource_instance_type_param
          @resource_instance_type_param ||= resource_instance.class.name.underscore.tr("/", "-")
        end

        def resource_instance_id
          @resource_instance_id ||= resource_instance.id
        end

        def admin
          @admin ||= gobierto_admin_admins(:tony)
        end

        def unauthorized_admin
          @unauthorized_admin ||= gobierto_admin_admins(:steve)
        end

        def site
          @site ||= sites(:madrid)
        end

        def test_permissions
          with(site: site, admin: unauthorized_admin) do
            visit @path
            assert has_content?("You are not authorized to perform this action")
            assert_equal edit_admin_admin_settings_path, current_path
          end
        end

        def test_create_custom_field_errors
          with(site: site, admin: admin) do
            visit @path

            click_link "Add new field"
            click_button "Create"

            assert has_alert?("can't be blank")
          end
        end

        def test_create_custom_field
          with(site: site, js: true, admin: admin) do
            visit @path

            click_link "Add new field"

            fill_in "custom_field_name_translations_en", with: "Introduction (test creation)"
            fill_in "custom_field_uid", with: "introduction"

            click_link "ES"
            fill_in "custom_field_name_translations_es", with: "Introducción (test de creación)"

            within ".site-module-check-boxes" do
              find("label", exact_text: "Long text").click
            end

            click_button "Create"

            assert has_message?("Custom field created correctly")

            assert ::GobiertoCommon::CustomField.where(class_name: resource_class.name).with_name_translation("Introduction (test creation)", :en).exists?

            custom_field = ::GobiertoCommon::CustomField.last
            assert_nil custom_field.instance
          end
        end

        def test_create_custom_field_at_instance_level
          admin.admin_groups << gobierto_admin_admin_groups(:madrid_manage_plans_group)

          with(site: site, js: true, admin: admin) do
            visit @instance_level_path

            click_link "Add new field"

            fill_in "custom_field_name_translations_en", with: "Instance introduction (test creation)"
            fill_in "custom_field_uid", with: "introduction"

            click_link "ES"
            fill_in "custom_field_name_translations_es", with: "Introducción para instancia (test de creación)"

            within ".site-module-check-boxes" do
              find("label", exact_text: "Long text").click
            end

            click_button "Create"

            assert has_message?("Custom field created correctly")

            assert ::GobiertoCommon::CustomField.where(
              class_name: resource_class_with_instance_levels.name
            ).with_name_translation(
              "Instance introduction (test creation)", :en
            ).exists?

            custom_field = ::GobiertoCommon::CustomField.last
            assert_not_nil custom_field.instance
            assert_equal resource_instance, custom_field.instance
          end
        end

        def test_create_date_custom_field
          with(site: site, js: true, admin: admin) do
            visit @path

            click_link "Add new field"

            fill_in "custom_field_name_translations_en", with: "Date custom field"
            fill_in "custom_field_uid", with: "date-custom-field"

            click_link "ES"
            fill_in "custom_field_name_translations_es", with: "Fecha custom field"

            within(".site-module-check-boxes") do find("label", exact_text: "Date").click end

            within "#date" do
              find("label", exact_text: "Date and time").click
            end

            click_button "Create"

            assert has_message?("Custom field created correctly")

            custom_field = ::GobiertoCommon::CustomField.last

            assert_equal "date", custom_field.field_type
            assert_equal "datetime", custom_field.options["configuration"]["date_type"]
          end
        end
      end
    end
  end
end
