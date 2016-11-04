require "test_helper"

class GobiertoBudgets::HomePageTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_budgets_site_path
  end

  def site
    @site ||= sites(:acme)
  end

  def test_greeting
    with_current_site(site) do
      visit gobierto_budgets_budgets_path

      assert has_content?("Acme Corp. / Budgets")
      assert has_content?("Main income and expenses from your council")
    end
  end
end
