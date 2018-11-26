# frozen_string_literal: true

require "test_helper"

class SearchBoxTest < ActionDispatch::IntegrationTest

  def site
    @site ||= sites(:madrid)
  end

  def test_search_box_with_algoliasearch
    ::GobiertoCommon::Search.stubs(:algoliasearch_configured?).returns(true)

    with_current_site(site) do
      visit gobierto_people_root_path

      assert has_selector?("#gobierto_search")

      visit gobierto_budgets_root_path

      assert has_selector?("#gobierto_search")
    end
  end

  def test_search_box_without_algoliasearch
    ::GobiertoCommon::Search.stubs(:algoliasearch_configured?).returns(false)

    with_current_site(site) do
      visit gobierto_people_root_path
      assert has_no_selector?("#gobierto_search")

      visit gobierto_budgets_root_path
      assert has_selector?(".search-box_input") # GobiertoBudgets search is shown instead

      visit gobierto_budgets_receipt_path
      assert has_selector?(".search-box_input") # fallback to current year
    end
  end

end
