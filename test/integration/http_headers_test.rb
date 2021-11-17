# frozen_string_literal: true

require "test_helper"

class HttpHeadersTest < ActionDispatch::IntegrationTest
  def site
    @site ||= sites(:madrid)
  end

  def user
    @user ||= users(:dennis)
  end

  def test_anonymous_user_cache_control
    with_current_site(site) do
      visit gobierto_people_root_path
      assert page.response_headers["Cache-Control"].include?("public")
    end
  end

  def test_logged_user_cache_control
    with_signed_in_user(user) do
      visit user_settings_path
      assert page.response_headers["Cache-Control"].include?("private")
    end
  end
end
