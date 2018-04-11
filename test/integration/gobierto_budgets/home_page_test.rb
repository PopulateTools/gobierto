# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::HomePageTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_budgets_root_path(last_year)
  end

  def placed_site
    @placed_site ||= sites(:madrid)
  end

  def organization_site
    @organization_site ||= sites(:organization_wadus)
  end

  def last_year
    GobiertoBudgets::SearchEngineConfiguration::Year.last
  end

  def test_greeting
    with_each_current_site(placed_site, organization_site) do
      visit @path

      assert has_content?("Budgets")
      assert has_content?(last_year)
    end
  end

  def test_menu_subsections
    with_each_current_site(placed_site, organization_site) do
      visit @path

      within "nav.sub-nav" do
        assert has_link? "Budgets"
        assert has_link? "Execution"
        assert has_link? "Guide"
        assert has_link? "Receipt"
        assert has_link? "Data"
      end
    end
  end

  def test_metric_boxes
    with_each_current_site(placed_site, organization_site) do
      visit @path

      assert has_css?(".metric_box h3", text: "Expenses per inhabitant")
      assert has_css?(".metric_box h3", text: "Total expenses")
      assert has_css?(".metric_box h3", text: "Executed")
      assert has_css?(".metric_box h3", text: "Inhabitants")
      assert has_css?(".metric_box h3", text: "Debt")
      assert page.all(".metric_box .metric").all? { |e| e.text =~ /(\d+)|Not avail./ }
    end
  end
end
