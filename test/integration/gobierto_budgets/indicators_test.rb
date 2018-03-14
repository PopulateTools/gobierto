# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::IndicatorsTest < ActionDispatch::IntegrationTest
  def site
    @site ||= sites(:madrid)
  end

  def test_greeting
    with_current_site(site) do
      visit gobierto_budgets_indicators_path

      assert has_content?("Understand the budgets of Madrid
                           through its main figures: gross savings, per capita
                           investment or investment financing.")
    end
  end
end
