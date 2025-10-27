# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  module GobiertoAdmin
    class UpdateCustomFieldTest < ActionDispatch::IntegrationTest
      attr_reader(
        :path,
        :instance_level_path,
        :global_custom_field,
        :instance_level_custom_field,
        :instance,
        :admin,
        :unauthorized_admin,
        :site
      )

      def setup
        super
        @site = sites(:madrid)
        @admin = gobierto_admin_admins(:tony)
        @unauthorized_admin = gobierto_admin_admins(:steve)
        @global_custom_field = gobierto_common_custom_fields(:madrid_node_global)
        @instance_level_custom_field = gobierto_common_custom_fields(:madrid_economic_plan_node_instance_level)
        @instance = gobierto_plans_plans(:economic_plan)
        @path = edit_admin_common_custom_fields_custom_field_path(global_custom_field)
        @instance_level_path = edit_admin_common_custom_fields_custom_field_path(instance_level_custom_field)
        @issues_vocabulary = gobierto_common_vocabularies(:issues_vocabulary)
        admin.admin_groups << gobierto_admin_admin_groups(:madrid_edit_all_projects_group)
      end

      def test_permissions
        with(site: site, admin: unauthorized_admin) do
          visit @path
          assert has_content?("You are not authorized to perform this action")
          assert_equal edit_admin_admin_settings_path, current_path
        end
      end

      def test_update_global_custom_field
        with(site: site, js: true, admin: admin) do
          visit @path

          fill_in "custom_field_name_translations_en", with: "Updated"
          fill_in "custom_field_uid", with: "updated"

          click_link "ES"
          fill_in "custom_field_name_translations_es", with: "Actualizado"

          click_button "Update"

          assert has_message?("Custom field updated correctly")

          global_custom_field.reload

          assert_nil global_custom_field.instance
          assert_equal "Updated", global_custom_field.name
        end
      end

      def test_update_instance_level_custom_field
        with(site: site, js: true, admin: admin) do
          visit @instance_level_path

          assert has_content? instance.title

          fill_in "custom_field_name_translations_en", with: "Updated"
          fill_in "custom_field_uid", with: "updated"

          click_link "ES"
          fill_in "custom_field_name_translations_es", with: "Actualizado"

          click_button "Update"

          assert has_message?("Custom field updated correctly")
          assert has_content?("Custom fields of #{instance.title}")

          instance_level_custom_field.reload

          assert_not_nil instance_level_custom_field.instance
          assert_equal instance, instance_level_custom_field.instance
        end
      end
    end
  end
end
