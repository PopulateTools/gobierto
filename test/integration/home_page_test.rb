# frozen_string_literal: true

require "test_helper"

class HomePageTest < ActionDispatch::IntegrationTest
  def setup
    super
    @path = root_path
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_greeting_to_first_active_module
    with_current_site(site) do
      visit @path

      assert has_content?("Participation")
      assert_equal 200, page.status_code
    end
  end
end
