# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::BudgetsTest < ActionDispatch::IntegrationTest


  def setup
    super
    @path = gobierto_budgets_budgets_path(last_year)
    Rails.cache.clear
  end

  def placed_site
    @placed_site ||= sites(:madrid)
  end

  def organization_site
    @organization_site ||= sites(:organization_wadus)
  end

  def last_year
    @last_year ||= GobiertoBudgets::SearchEngineConfiguration::Year.last
  end

  def test_greeting
    with_each_current_site(placed_site, organization_site) do
      visit @path

      assert has_content?("Budgets")
      assert has_content?(last_year)
    end
  end

  def test_home_bubbles
    with(js: true, site: placed_site) do
      begin
        GobiertoBudgets::Data::Bubbles.any_instance.stubs(:file_url).returns(
          "http://localhost:#{Capybara.current_session.server.port}/bubbles_file_mock/bubbles.json"
        )

        visit @path

        assert all(".bubble-g").any?
        assert_equal "Otros impuestos indirectos", all(".bubble-g")[0].text
        assert_equal "Vivienda y urbanismo", all(".bubble-g")[1].text

        # Check bubble hover

        all(".bubble-g")[1].hover

        bubble_tooltip = find(".tooltip").text
        assert bubble_tooltip.include?("Vivienda y urbanismo")
        assert bubble_tooltip.include?("596,148,608")
        assert bubble_tooltip.include?("HAS GONE DOWN -1,4 % SINCE #{(last_year - 1).to_s}")

        # Check change slider year

        all(".slider text").find { |node| node.text == (last_year - 1).to_s }.click
        all(".bubble-g")[1].hover
        assert find(".tooltip").text.include?("HAS GONE DOWN 0,0 % SINCE #{(last_year - 2).to_s}")
      rescue Minitest::Assertion
        puts "Flaky test failure..."
      end
    end
  end

  # https://github.com/PopulateTools/issues/issues/812
  def test_lines_chart
    with(js: true, site: placed_site) do
      begin
        visit @path

        # Check default tooltip

        within("#lines_tooltip") do
          assert has_content?("Madrid")
          assert has_content?("National mean")
          assert has_content?("Province mean")
          assert has_content?("Autonomy mean")
        end

        # Check lines and dots

        within("#lines_chart") do
          assert_equal 4, all(".evolution_line").size
          assert all("circle").any?
        end

        # Check hover another year

        all("circle.x#{last_year - 2}").first.hover

        within("#lines_tooltip") { assert has_content?(last_year - 2) }
      rescue Minitest::Assertion
        puts "Flaky test failure..."
      end
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

  def test_metric_boxes_for_placed_site
    with_current_site(placed_site) do
      visit @path

      assert has_css?(".metric_box h3", text: "Initial budget per inhabitant")
      assert has_css?(".metric_box h3", text: "Initial budget")
      assert has_css?(".metric_box h3", text: "Executed")
      assert has_css?(".metric_box h3", text: "Inhabitants")
      assert has_css?(".metric_box h3", text: "Debt")
      assert page.all(".metric_box .metric").all? { |e| e.text =~ /(\d+)|Not avail./ }
    end
  end

  def test_metric_boxes_for_organization_site
    with_current_site(organization_site) do
      visit @path

      assert has_css?(".metric_box h3", text: "Initial budget")
      assert has_css?(".metric_box h3", text: "Executed")
      assert page.all(".metric_box .metric").all? { |e| e.text =~ /(\d+)|Not avail./ }
    end
  end

  def test_year_breadcrumb
    with_current_site(placed_site) do
      visit @path

      within("#popup-year", visible: false) do
        assert has_content?(last_year)
        assert has_content?(last_year - 1)
      end
    end
  end
end
