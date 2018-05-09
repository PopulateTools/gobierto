# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::HomePageTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_budgets_root_path(last_year)
    Rails.cache.clear
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
    with_current_site(placed_site) do
      visit @path

      assert has_css?(".metric_box h3", text: "Expenses per inhabitant")
      assert has_css?(".metric_box h3", text: "Total expenses")
      assert has_css?(".metric_box h3", text: "Executed")
      assert has_css?(".metric_box h3", text: "Inhabitants")
      assert has_css?(".metric_box h3", text: "Debt")
      assert page.all(".metric_box .metric").all? { |e| e.text =~ /(\d+)|Not avail./ }
    end
    with_current_site(organization_site) do
      visit @path

      assert has_css?(".metric_box h3", text: "Total expenses")
      assert has_css?(".metric_box h3", text: "Executed")
      assert has_css?(".metric_box h3", text: "Debt")
      assert page.all(".metric_box .metric").all? { |e| e.text =~ /(\d+)|Not avail./ }
    end
  end

  def test_year_breadcrumb
    available_years = [2010, 2011]
    GobiertoBudgets::SearchEngineConfiguration::Year.expects(:with_data).returns(available_years)

    with_current_site(placed_site) do
      visit gobierto_budgets_root_path(available_years.first)

      within '#popup-year' do
        assert has_content? available_years.first
        assert has_content? available_years.second
        assert has_selector?("tr", count: available_years.size)
      end
    end
  end
end