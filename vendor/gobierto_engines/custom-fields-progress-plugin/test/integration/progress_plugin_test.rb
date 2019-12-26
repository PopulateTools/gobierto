# frozen_string_literal: true

require "test_helper"

class ProgressPluginTest < ActionDispatch::IntegrationTest

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
    gobierto_common_custom_field_records(:political_agendas_progress_custom_field_record)
  end

  def source_custom_field_of_progress_calculations
    gobierto_common_custom_field_records(:political_agendas_human_resources_table_custom_field_record)
  end

  def clear_source_payload
    source_custom_field_of_progress_calculations.update_attributes!(payload: { human_resources_table: [] })
  end

  def set_source_payload
    source_custom_field_of_progress_calculations.update_attributes!(
      payload: {
        human_resources_table: [
          {
            human_resource: ActiveRecord::FixtureSet.identify(:human_resources_supervisor),
            cost: 35_000,
            start_date: 1.day.ago.to_date.to_s,
            end_date: 1.day.from_now.to_date.to_s
          }
        ]
      }
    )
  end

  def test_show
    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      assert_no_selector("#custom_field_progress")
      assert_equal "-", evaluate_script("$('input[data-plugin-type=\"progress\"]').val()")
      assert_equal 50.0, project.progress
      assert_nil custom_field_record.payload
    end
  end

  def test_save_with_empty_source_payload_updates_progress
    clear_source_payload

    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      within "form" do
        within "div.widget_save_v2.editor" do
          click_button "Save"
        end
      end

      assert_no_selector("#custom_field_progress")
      assert_equal "-", evaluate_script("$('input[data-plugin-type=\"progress\"]').val()")
      assert_nil project.progress
      assert_nil custom_field_record.payload
    end
  end

  def test_save_item_with_values_on_source_payload
    set_source_payload

    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      within "form" do
        within "div.widget_save_v2.editor" do
          click_button "Save"
        end
      end

      assert_no_selector("#custom_field_progress")
      assert_equal "50%", evaluate_script("$('input[data-plugin-type=\"progress\"]').val()")
      assert_equal 50.0, project.progress
      assert_equal 0.5, custom_field_record.payload
    end
  end
end
