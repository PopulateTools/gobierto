# frozen_string_literal: true

require "test_helper"

class IndicatorsPluginTest < ActionDispatch::IntegrationTest

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
    gobierto_common_custom_field_records(:political_agendas_indicators_custom_field_record)
  end

  def clear_custom_field_payload
    custom_field_record.update_attributes!(payload: {})
  end

  def lose_cell_focus
    within(first(".slick-row.even")) { all("div")[0].click }
  end

  def click_add_row_button
    all(".slick-row").last.all(".slick-cell")[1].click
  end

  def click_cell(x, y)
    real_y = y - 1

    # HACK: first click in a different row to lose focus
    other_y = real_y.zero? ? 1 : real_y - 1
    find(".slick-row[style='top:#{25 * other_y}px']").find(".slick-cell.r#{x}").double_click

    find(".slick-row[style='top:#{25 * real_y}px']").double_click
  end

  def fill_active_select(option_text)
    within(".slick-row") { find("select").select(option_text) }
    lose_cell_focus
  end

  def fill_active_input(value)
    within(".slickgrid-container") { find("input[type='text']").set(value) }
    lose_cell_focus
  end

  def slickgrid_column_count
    all(".slick-header-column").size - 3
  end

  def slickgrid_row_count
    all(".slick-row").size + 1
  end

  def mark_row_for_deletion(row_index)
    all(".slick-row")[row_index].find("input[type='checkbox']").click
  end

  def test_show
    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      within first(".slick-row.even") do
        assert has_content?("Raw savings")
        assert has_content?("5")
      end

      within first(".slick-row.odd") do
        assert has_content?("Net savings")
        assert has_content?("50.1")
      end
    end
  end

  def test_show_when_no_data
    clear_custom_field_payload

    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      assert_equal 2, slickgrid_row_count
      assert_equal 3, slickgrid_column_count
    end
  end

  def test_add_row
    clear_custom_field_payload

    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      click_add_row_button
      fill_active_select("Raw savings")
      click_cell(2, 1)
      fill_active_input(666)

      within(".moderator") { click_button "Save" }

      within first(".slick-row.even") do
        assert has_content?("Raw savings")
        assert has_content?("666")
      end

      assert_equal 3, slickgrid_row_count
      assert_equal 3, slickgrid_row_count

      assert has_content? "Project updated correctly"
    end
  end

  def test_delete_row
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

  def test_delete_column
    with(site: site, js: true, admin: admin) do
      visit edit_admin_plans_plan_project_path(plan, project)

      assert has_content?("2019-01")

      click_cell(2, 1)
      fill_active_input("")

      click_cell(2, 2)
      fill_active_input("")

      within(".moderator") { click_button "Save" }

      assert has_content? "Project updated correctly"
      refute has_content?("2019-01")
    end
  end

end
