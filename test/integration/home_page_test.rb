require "test_helper"

class HomePageTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = root_path
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_greeting
    with_current_site(site) do
      visit @root_path

      assert has_content?("Main income and expenses from your council")
    end
  end
end
