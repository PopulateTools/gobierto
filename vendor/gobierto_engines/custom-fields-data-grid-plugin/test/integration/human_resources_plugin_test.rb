# frozen_string_literal: true

require "test_helper"

class HumanResourcesPluginTest < ActionDispatch::IntegrationTest

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
    gobierto_common_custom_field_records(:political_agendas_human_resources_custom_field_record)
  end

  def clear_custom_field_payload
    custom_field_record.update_attributes!(payload: {})
  end

  def slickgrid_column_count
    # check for invisible elements, otherwise fails in headless
    all(".slick-header-column", visible: false).size
  end

  def slickgrid_row_count
    all(".slick-row").size + 1
  end

  def mark_row_for_deletion(row_index)
    all(".slick-row")[row_index].find("input[type='checkbox']").click
  end

  def within_plugin(params = nil)
    within("#custom_field_human-resources") do
      if params
        within(params) { yield }
      else
        yield
      end
    end
  end

  def test_show
    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      within_plugin do
        assert_equal 5, slickgrid_row_count

        assert has_content?("Supervisor")
        assert has_content?("Employee")

        assert has_content?("35000")
        assert has_content?("25000")
        assert has_content?("20000")

        assert has_content?("01/01/2018")
        assert has_content?("31/12/2018")
      end
    end
  end

  def test_show_when_no_data
    clear_custom_field_payload

    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      within_plugin do
        assert_equal 2, slickgrid_row_count
        assert_equal 5, slickgrid_column_count
      end
    end
  end

  def test_add_row
    skip "Pending"
  end

  def test_delete_row
    skip
    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      assert has_content?("Raw savings")
      assert has_content?("Net savings")

      mark_row_for_deletion(1)

      click_button "Delete selected rows"
      within(".moderator") { click_button "Save" }

      assert has_content?("Raw savings")
      refute has_content?("Net savings")
    end
  end

end
