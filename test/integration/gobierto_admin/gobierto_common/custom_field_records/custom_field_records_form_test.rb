# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    module CustomFieldRecords
      class CustomFieldRecordsFormTest < ActionDispatch::IntegrationTest
        def path
          @path ||= edit_admin_citizens_charters_charter_path(charter)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def site
          @site ||= sites(:madrid)
        end

        def charter
          @charter ||= gobierto_citizens_charters_charters(:teleassistance_charter)
        end

        def instance_with_custom_fields
          @instance_with_custom_fields ||= gobierto_plans_plans(:strategic_plan)
        end

        def resource_with_instance_level_custom_fields_path
          @resource_with_instance_level_custom_fields_path ||= new_admin_plans_plan_project_path(plan_id: instance_with_custom_fields.id)
        end

        def instance_without_custom_fields
          @instance_without_custom_fields ||= gobierto_plans_plans(:government_plan)
        end

        def resource_without_instance_level_custom_fields_path
          @resource_without_instance_level_custom_fields_path ||= new_admin_plans_plan_project_path(plan_id: instance_without_custom_fields.id)
        end

        def charters_custom_fields
          @charters_custom_fields ||= site.custom_fields.where(class_name: "GobiertoCitizensCharters::Charter")
        end

        def global_custom_field
          @global_custom_field ||= gobierto_common_custom_fields(:madrid_node_global)
        end

        def instance_level_custom_field
          @instance_level_custom_field ||= gobierto_common_custom_fields(:madrid_node_instance_level)
        end

        def test_custom_fields_record
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit path
              charters_custom_fields.each do |custom_field|
                assert has_content? custom_field.name
              end
            end
          end
        end

        def test_instance_level_custom_fields
          with(site: site, js: false, admin: admin) do
            visit resource_with_instance_level_custom_fields_path

            assert has_content? global_custom_field.name
            assert has_content? instance_level_custom_field.name
          end
        end

        def test_custom_fields_without_custom_fields
          with(site: site, js: false, admin: admin) do
            visit resource_without_instance_level_custom_fields_path

            assert has_content? global_custom_field.name
            assert has_no_content? instance_level_custom_field.name
          end
        end
      end
    end
  end
end
