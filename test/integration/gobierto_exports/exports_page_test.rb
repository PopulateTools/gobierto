require "test_helper"

class HomePageTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = gobierto_exports_root_path
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_index
    with_current_site(site) do
      visit @path

      assert has_selector?("h1", text: "Download data")
      assert has_selector?("h2", text: "Officials and Agendas")
    end
  end
end
