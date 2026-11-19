# frozen_string_literal: true

require "test_helper"

class LocaleCookieTest < GobiertoControllerTest
  def site
    @site ||= sites(:madrid)
  end

  def admin
    @admin ||= gobierto_admin_admins(:natasha)
  end

  def locale_cookie_header
    Array(response.headers["Set-Cookie"]).flat_map { |header| header.split("\n") }.find { |cookie| cookie.start_with?("locale=") }
  end

  def test_public_locale_cookie_is_http_only
    with_current_site(site) do
      get gobierto_people_root_url(locale: "en")

      assert_match(/;\s*httponly/i, locale_cookie_header)
    end
  end

  def test_admin_locale_cookie_is_http_only
    with_current_site(site) do
      with_signed_in_admin(admin) do
        get admin_sites_url(locale: "en")

        assert_match(/;\s*httponly/i, locale_cookie_header)
      end
    end
  end
end
