# frozen_string_literal: true

require "test_helper"

class SearchBoxTest < ActionDispatch::IntegrationTest

  def site
    @site ||= sites(:madrid)
  end

  def test_search_box_with_search_documents
    site.people.each(&:update_pg_search_document)

    with_current_site(site) do
      visit gobierto_people_root_path

      assert has_selector?("#gobierto_search")

      visit gobierto_budgets_root_path

      assert has_selector?("#gobierto_search")
    end
  end

  def test_search_box_use
    site.people.each(&:update_pg_search_document)

    with(site: site, js: true) do
      visit gobierto_people_root_path

      find("#gobierto_search").send_keys("ric")

      sleep 2

      assert has_content? "Richard Rider"
    end
  end

  def test_search_box_without_search_documents
    site.pg_search_documents.destroy_all

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
