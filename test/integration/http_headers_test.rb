# frozen_string_literal: true

require "test_helper"

class HttpHeadersTest < ActionDispatch::IntegrationTest
  def site
    @site ||= sites(:madrid)
  end

  def user
    @user ||= users(:dennis)
  end

  # Rails reorders Cache-Control directives when it serializes the response, so
  # compare the set of directives instead of the literal string.
  def directives(header)
    page.response_headers[header].to_s.split(",").map(&:strip).sort
  end

  def test_anonymous_user_cache_control
    with_current_site(site) do
      visit gobierto_people_root_path

      assert_equal ["max-age=900", "private"], directives("Cache-Control")
    end
  end

  # Locale and session live in cookies, not in the URL, so a cached page must
  # not survive a locale switch or a sign in/out.
  def test_anonymous_user_varies_by_cookie
    with_current_site(site) do
      visit gobierto_people_root_path

      assert_includes directives("Vary"), "Cookie"
    end
  end

  def test_logged_user_cache_control
    with_signed_in_user(user) do
      visit user_settings_path

      assert_equal "private", page.response_headers["Cache-Control"]
    end
  end
end
