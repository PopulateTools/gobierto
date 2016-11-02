require "test_helper"

class HomePageTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = root_path
  end

  def site
    @site ||= sites(:acme)
  end

  def test_greeting
    # FIXME. Skipping this test case until we have proper fixtures to populate
    # the Elasticsearch indices in test environment.
    skip

    with_current_site(site) do
      visit @root_path

      assert has_content?("Welcome to Gobierto.")
    end
  end
end
