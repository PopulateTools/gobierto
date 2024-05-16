# frozen_string_literal: true

require "test_helper"
require "factories/budget_line_factory"

class GobiertoBudgets::BudgetLineIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    super
    ::GobiertoCommon::CacheService.new(placed_site, "GobiertoBudgets").clear
    ::GobiertoCommon::CacheService.new(organization_site, "GobiertoBudgets").clear
    @path = gobierto_budgets_budget_line_path("1", last_year, GobiertoBudgets::EconomicArea.area_name, GobiertoBudgets::BudgetLine::EXPENSE)
    @budget_line_factory = BudgetLineFactory.new(year: last_year)
  end

  def teardown
    @budget_line_factory.teardown
  end

  def placed_site
    @placed_site ||= sites(:madrid)
  end

  def organization_site
    @organization_site ||= sites(:organization_wadus)
  end

  def last_year
    GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last
  end

  def feedback_ack_message
    "100 % of the people who voted said that don't understand this budget line"
  end

  def subscription_ack_message
    "Good! Check your email and click the link"
  end

  def enable_budget_line_feedback
    ApplicationController.any_instance.stubs(:budget_lines_feedback_active?).returns(true)
  end

  def metric_box(type)
    ".metric_box[data-box='#{type}']"
  end

  def default_test_context
    { site: placed_site, js: true }
  end

  def test_budget_line_information
    with(default_test_context) do
      visit @path

      assert has_content?("Personal expenses (custom, translated)")
      assert has_content?("Órganos de gobierno y personal directivo")
    end
  end

  def test_metric_boxes
    budget_line_attrs = { organization_id: placed_site.organization_id, population: 10 }
    amount = 150
    amount_updated = 200
    f1 = BudgetLineFactory.new(budget_line_attrs.merge(amount: amount, indexes: [:forecast]))
    f2 = BudgetLineFactory.new(budget_line_attrs.merge(amount: amount_updated, indexes: [:forecast_updated]))

    with(default_test_context.merge(factories: [f1, f2])) do
      visit @path

      within(metric_box(:planned)) do
        assert has_content?("Initial budget\n#{amount}")
        assert has_content?("Current amount: #{amount_updated}")
      end

      within(metric_box(:planned_per_inhabitant)) do
        assert has_content?("Initial budget / inh.\n15.00")
        assert has_content?("Current amount / hab.: 20.00")
      end

      assert has_css?(".metric_box h3", text: "% execution")
      assert has_css?(".metric_box h3", text: "% over the total")
      assert has_css?(".metric_box h3", text: "Avg. expense in the province")
      assert page.all(".metric_box .metric").all? { |e| e.text =~ /(\d+)|Not avail./ }
    end
  end

  def test_invalid_budget_line_url
    with_each_current_site(placed_site, organization_site) do
      visit gobierto_budgets_budget_line_path("1", last_year, GobiertoBudgets::EconomicArea.area_name, "foo")

      assert_equal 400, status_code
    end
  end

  def test_request_more_information_and_subscribe
    enable_budget_line_feedback

    with(default_test_context) do
      visit @path

      click_link "Ask your #{placed_site.organization_name}"

      within("#load_ask_more_information") do
        fill_in :email, with: "user@email.com"
      end

      click_button "Send"

      assert has_content? subscription_ack_message
    end
  end

  def test_request_more_information_and_subscribe_as_spam
    enable_budget_line_feedback

    with(default_test_context) do
      visit @path

      click_link "Ask your #{placed_site.organization_name}"

      within("#load_ask_more_information") do
        fill_in :email, with: "spam@email.com"

        # find("#ic_email", visible: false).set("spam@email.com")
        page.execute_script('document.getElementById("ic_email").innerText = "spam@email.com"')
      end

      click_button "Send"

      assert has_no_content?(subscription_ack_message)
    end
  end

  def test_send_feedback_and_subscribe
    enable_budget_line_feedback

    with(default_test_context) do
      visit @path

      click_link "Raise your hand"

      within(".yes_no") { click_link "No" }

      assert has_content? feedback_ack_message

      fill_in :email, with: "user@email.com"

      click_button "Follow"

      assert has_content? subscription_ack_message
    end
  end

  def test_send_feedback_and_subscribe_as_spam
    enable_budget_line_feedback

    with(default_test_context) do
      visit @path

      click_link "Raise your hand"

      within(".yes_no") { click_link "No" }

      assert has_content? feedback_ack_message

      fill_in :email, with: "spam@email.com"

      # find("#ic_email", visible: false).set("spam@email.com")
      page.execute_script('document.getElementById("ic_email").innerText = "spam@email.com"')

      click_button "Follow"

      assert has_no_content?(subscription_ack_message)
    end
  end

end
