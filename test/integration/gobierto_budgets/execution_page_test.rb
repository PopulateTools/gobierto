# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::ExecutionPpageTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_budgets_budgets_execution_path(last_year)
  end

  def placed_site
    @placed_site ||= sites(:madrid)
  end

  def organization_site
    @organization_site ||= sites(:organization_wadus)
  end

  def last_year
    2016
  end

  def test_execution_information
    with_each_current_site(placed_site, organization_site) do |site|
      visit @path

      assert has_content?("Budget execution")
    end
  end
end
