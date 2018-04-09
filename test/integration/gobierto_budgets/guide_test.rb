# frozen_string_literal: true

require "test_helper"

class GobiertoBudgets::GuideTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_budgets_budgets_guide_path
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
    with_each_current_site(placed_site, organization_site) do |site|
      visit @path

      assert has_content?("How a municipal budget works")
      assert has_content?("In #{last_year} were entered...")
    end
  end
end
