# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoPlans
    class IndicatorsCreationTest < ActionDispatch::IntegrationTest
      include Integration::AdminGroupsConcern

      attr_reader :plan, :site, :admin, :path_new_indicator, :plan_project_edit_path

      def setup
        super
        @path_new_indicator = admin_common_custom_fields_module_resources_path
        @plan_project_edit_path = edit_admin_plans_plan_project_path(plan_id: plan.id, id: project.id)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def plan
        @plan ||= gobierto_plans_plans(:strategic_plan)
      end

      def project
        @project ||= gobierto_plans_nodes(:scholarships_kindergartens)
      end

      def indicator_configuration
        {
          columns: [
              {
                id: "indicator_name",
                type: "text",
                name_translations: {
                  en: "Annotation indicator",
                  es: "Anotacion Indicador"
                }
              }
          ]
        }
      end

      def test_creation_new_indicator
        with(js: true) do
          with_signed_in_admin(admin) do
            with_current_site(site) do

              # do all steps will make this test Flaky. it keeps for documente the full creation
              #
              # visit admin custom_field page
              # visit path_new_indicator

              # go to custom field for plan instances
              # assert find("h1", text: "Custom fields")
              # find_link(plan.title_translations["en"]).click

              # move foward to next page
              # find_link("Project").click

              visit admin_common_custom_fields_module_resource_instance_level_resource_path(module_resource_name: "GobiertoPlans::Plan", id: plan.id)
              find_link("Project").click

              # page index for custom field already created
              find_link("Add new field").click

              fill_in "custom_field_name_translations_en", with: "indicator name"
              click_on "ES"
              fill_in "custom_field_name_translations_es", with: "nombre indicador"
              fill_in "custom_field_uid", with: "indicator-uid"

              page.execute_script("document.getElementById('custom_field_field_type_plugin').click()")
              page.execute_script("document.getElementById('custom_field_plugin_type_table').click()")

              fill_in "custom_field_plugin_configuration", with: indicator_configuration.to_json, fill_options: { clear: :backspace }
              page.execute_script("document.getElementById('new_custom_field').submit()")
              assert has_content? "Custom field created correctly"
            end
          end
        end
      end

    end
  end
end
