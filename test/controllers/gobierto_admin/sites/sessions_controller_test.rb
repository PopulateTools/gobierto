# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class Sites::SessionsControllerTest < GobiertoControllerTest
    def setup
      super
      sign_in_admin(admin)
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def site_madrid
      @site_madrid ||= sites(:madrid)
    end

    def site_santander
      @site_santander ||= sites(:santander)
    end

    def test_create
      with_current_site(site_madrid) do
        post(
          admin_sites_sessions_path,
          params: { site_id: site_santander.id },
          headers: { "HTTP_REFERER" => admin_root_url }
        )
        assert_redirected_to admin_root_url
      end
    end

    def test_create_from_edit_admin_site_path
      with_current_site(site_madrid) do
        post(
          admin_sites_sessions_path,
          params: { site_id: site_santander.id },
          headers: { "HTTP_REFERER" => edit_admin_site_url(site_madrid) }
        )
        assert_redirected_to edit_admin_site_path(site_santander)
      end

      with_current_site(site_santander) do
        post(
          admin_sites_sessions_path,
          params: { site_id: site_madrid.id },
          headers: { "HTTP_REFERER" => edit_admin_site_url(site_santander) }
        )
        assert_redirected_to edit_admin_site_path(site_madrid)
      end
    end
  end
end
