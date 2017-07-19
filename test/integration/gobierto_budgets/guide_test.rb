require "test_helper"

class GobiertoBudgets::GuideTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_budgets_budgets_guide_path
  end

  def site
    @site ||= sites(:madrid)
  end

  def last_year
    GobiertoBudgets::SearchEngineConfiguration::Year.last
  end

  def test_greeting
    with_current_site(site) do
      visit @path

      assert has_content?("How a municipal budget works")
      assert has_content?("In #{last_year} were entered...")
    end
  end
end
