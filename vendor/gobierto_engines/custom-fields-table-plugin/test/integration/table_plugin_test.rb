# frozen_string_literal: true

require "test_helper"

class TablePluginTest < ActionDispatch::IntegrationTest

  def site
    @site ||= sites(:madrid)
  end

  def admin
    @admin ||= gobierto_admin_admins(:natasha)
  end

  def project
    @project ||= gobierto_plans_nodes(:political_agendas)
  end

  def plan
    @plan ||= gobierto_plans_plans(:strategic_plan)
  end

  def custom_field_record
    gobierto_common_custom_field_records(:political_agendas_table_custom_field_record)
  end

  def custom_field
    gobierto_common_custom_fields(:madrid_custom_field_table_plugin)
  end

  def clear_payload
    custom_field_record.update_attributes!(payload: { human_resources: [] })
  end

  def set_payload
    custom_field_record.update_attributes!(
      payload: {
        directory: [
          {
            person: "John",
            phone_number: 666_666_666,
            email: "john@example.org",
            birthdate: "1980-12-28",
            position: ActiveRecord::FixtureSet.identify(:human_resources_supervisor),
            indicator: ActiveRecord::FixtureSet.identify(:indicators_net_savings)
          }
        ]
      }
    )
  end

  def set_table_with_one_vocabulary
    custom_field.update_attributes!(
      options: {
        configuration: {
          plugin_type: "table",
          plugin_configuration: {
            columns: [
              {
                "id": "position",
                "type": "vocabulary",
                "dataSource": "/admin/api/vocabularies/#{ ActiveRecord::FixtureSet.identify(:human_resources_vocabulary) }",
                "name_translations": {
                  "en": "Position",
                  "es": "Puesto"
                }
              }
            ]
          }
        }
      }
    )
  end

  def test_show_with_data
    set_payload

    with(site: site, js: true, admin: admin, window_size: :xl) do
      visit edit_admin_plans_plan_project_path(plan, project)
      within("#custom_field_directory") do
        assert has_content?("John")
        assert has_content?("666666666")
        assert has_content?("john@example.org")
        assert has_content?("1980-12-28")
        assert has_content?("Supervisor")
        assert has_content?("Net savings")
      end
    end
  end

  def test_show_with_one_vocabulary_column
    set_payload
    set_table_with_one_vocabulary

    with(site: site, js: true, admin: admin, window_size: :xl) do
      visit edit_admin_plans_plan_project_path(plan, project)
      within("#custom_field_directory") do
        assert has_no_content?("John")
        assert has_no_content?("666666666")
        assert has_no_content?("john@example.org")
        assert has_no_content?("1980-12-28")
        assert has_content?("Supervisor")
        assert has_no_content?("Net savings")
      end
    end
  end

end
