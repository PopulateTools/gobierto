# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::ElaborationTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_budgets_root_path
    Rails.cache.clear
  end

  def placed_site
    @placed_site ||= sites(:madrid)
  end

  def organization_site
    @organization_site ||= sites(:organization_wadus)
  end

  def current_year
    Date.today.year
  end

  def test_greeting
    with_each_current_site(placed_site, organization_site) do
      visit @path

      assert has_content?("Budgets")
      assert has_content?(current_year)
    end
  end

  def test_menu_subsections
    with_each_current_site(placed_site, organization_site) do
      visit @path

      within "nav.sub-nav" do
        assert has_link? "Elaboration"
        assert has_link? "Budgets"
        assert has_link? "Execution"
        assert has_link? "Guide"
        assert has_link? "Receipt"
        assert has_link? "Data"
      end
    end
  end

  def test_metric_boxes
    with_current_site(placed_site) do
      visit @path

      assert has_css?(".metric_box h3", text: "Total expenses")
      assert has_css?(".metric_box h3", text: "Net savings")
    end

    with_current_site(organization_site) do
      visit @path

      assert has_css?(".metric_box h3", text: "Total expenses")
      assert has_css?(".metric_box h3", text: "Net savings")
    end
  end

  def test_income_tab
    with_javascript do
      with_current_site(placed_site) do
        visit @path

        within(:css, "#data-block") do
          click_link "Income"
        end
        assert has_css?(".metric_box h3", text: "Total income")
      end
    end
  end
end
