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

  def clear_custom_field_payload
    custom_field_record.update_attributes!(payload: nil)
  end

  def set_custom_field_payload
    custom_field_record.update_attributes!(
      payload: {
        human_resources: [
          {
            human_resource: ActiveRecord::FixtureSet.identify(:human_resources_supervisor),
            cost: 35_000,
            start_date: 3.years.from_now.to_date.to_s,
            end_date: 2.years.from_now.to_date.to_s
          }
        ]
      }
    )
  end

  def within_plugin(params = nil)
    within("#custom_field_progress") do
      if params
        within(params) { yield }
      else
        yield
      end
    end
  end

  def test_show
    clear_custom_field_payload

    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      within_plugin do
        assert has_content?("-")
      end
    end
  end

  def test_save_item
    set_custom_field_payload

    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      within "form" do
        within "div.widget_save_v2.editor" do
          click_button "Save"
        end
      end

      within_plugin do
        assert has_content?("100%")
      end
    end
  end
end
