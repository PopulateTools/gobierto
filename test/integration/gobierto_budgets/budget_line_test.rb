# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::BudgetLineIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_budgets_budget_line_path("1", last_year, GobiertoBudgets::EconomicArea.area_name, GobiertoBudgets::BudgetLine::EXPENSE)
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

  def feedback_ack_message
    "100 % of the people who voted said that don't understand this budget line"
  end

  def subscription_ack_message
    "Good! Check your email and click the link"
  end

  def enable_budget_line_feedback
    ApplicationController.any_instance.stubs(:budget_lines_feedback_active?).returns(true)
  end

  def test_budget_line_information
    with_each_current_site(placed_site, organization_site) do
      visit @path

      assert has_content?("Personal expenses (custom, translated)")
      assert has_content?("Órganos de gobierno y personal directivo")
    end
  end

  def test_metric_boxes
    with_each_current_site(placed_site, organization_site) do
      visit @path

      assert has_css?(".metric_box h3", text: "Expense plan. / inh.")
      assert has_css?(".metric_box h3", text: "Expense planned")
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

    with_javascript do
      with_current_site(placed_site) do
        visit @path

        click_link "Ask your #{placed_site.organization_name}"

        within("#load_ask_more_information") do
          fill_in :email, with: "user@email.com"
        end

        click_button "Send"

        assert has_content? subscription_ack_message
      end
    end
  end

  def test_request_more_information_and_subscribe_as_spam
    enable_budget_line_feedback

    with_javascript do
      with_current_site(placed_site) do
        visit @path

        click_link "Ask your #{placed_site.organization_name}"

        within("#load_ask_more_information") do
          fill_in :email, with: "spam@email.com"
          find("#ic_email", visible: false).set("spam@email.com")
        end

        click_button "Send"

        assert has_no_content?(subscription_ack_message)
      end
    end
  end

  def test_send_feedback_and_subscribe
    enable_budget_line_feedback

    with_javascript do
      with_current_site(placed_site) do
        visit @path

        click_link "Raise your hand"

        within(".yes_no") { click_link "No" }

        assert has_content? feedback_ack_message

        fill_in :email, with: "user@email.com"

        click_button "Follow"

        assert has_content? subscription_ack_message
      end
    end
  end

  def test_send_feedback_and_subscribe_as_spam
    enable_budget_line_feedback

    with_javascript do
      with_current_site(placed_site) do
        visit @path

        click_link "Raise your hand"

        within(".yes_no") { click_link "No" }

        assert has_content? feedback_ack_message

        fill_in :email, with: "spam@email.com"
        find("#ic_email", visible: false).set("spam@email.com")

        click_button "Follow"

        assert has_no_content?(subscription_ack_message)
      end
    end
  end

end
