# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  module GobiertoAdmin
    class DeleteCustomFieldTest < ActionDispatch::IntegrationTest
      attr_reader(
        :path,
        :instance_level_path,
        :global_custom_field,
        :instance_level_custom_field,
        :instance,
        :resource_class,
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
        @resource_class = GobiertoPlans::Node
        @path = admin_common_custom_fields_module_resource_custom_fields_path(module_resource_name: parameterize(resource_class.name))
        @instance_level_path = admin_common_custom_fields_module_resource_custom_fields_path(
          module_resource_name: parameterize(resource_class.name),
          instance_type: parameterize(instance.class.name),
          instance_id: instance.id
        )
        admin.admin_groups << gobierto_admin_admin_groups(:madrid_edit_all_projects_group)
      end

      def parameterize(class_name)
        class_name.underscore.tr("/", "-")
      end

      def test_delete_global_custom_field
        with(site: site, admin: admin) do
          visit path

          within "div#item-#{global_custom_field.id}" do
            click_link "Delete"
          end
          assert has_content? "Custom field successfully deleted"
          assert has_content? "Custom fields"
          assert has_no_content? global_custom_field.name
        end
      end

      def test_delete_instance_level_custom_field
        with(site: site, admin: admin) do
          visit instance_level_path

          within "div#item-#{instance_level_custom_field.id}" do
            click_link "Delete"
          end
          assert has_content? "Custom field successfully deleted"
          assert has_content? "Custom fields of #{instance.title}"
          assert has_no_content? instance_level_custom_field.name
        end
      end
    end
  end
end
