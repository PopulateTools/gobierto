require "test_helper"

module GobiertoAdmin
  class SiteSessionTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = admin_root_path
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_site_initialization
      with_signed_in_admin(admin) do
        visit @path

        within "#current-site-name" do
          assert has_content?(site.name)
        end
      end
    end

    def test_site_switch
      with_signed_in_admin(admin) do
        visit @path

        within "#managed-sites-list" do
          click_on site.name
        end

        within "#current-site-name" do
          assert has_content?(site.name)
        end
      end
    end
  end
end
