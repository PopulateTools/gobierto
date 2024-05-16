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

  def cms_page
    @cms_page ||= gobierto_cms_pages(:about_site)
  end

  def last_year
    GobiertoBudgetsData::GobiertoBudgets::SearchEngineConfiguration::Year.last
  end

  def test_greeting
    with_each_current_site(placed_site, organization_site) do
      visit @path

      assert has_content?("How a municipal budget works")
      assert has_content?("In #{last_year} were entered...")
    end
  end

  def test_overwrite_page
    placed_site.gobierto_budgets_settings.settings["budgets_guide_page"] = cms_page.id
    placed_site.gobierto_budgets_settings.save!

    with_current_site(placed_site) do
      visit @path

      assert has_content?("About site")
    end
  end
end
