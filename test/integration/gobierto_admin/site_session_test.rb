# frozen_string_literal: true

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

    def madrid_site
      @madrid_site ||= sites(:madrid)
    end

    def santander_site
      @santander_site ||= sites(:santander)
    end

    def test_site_switch
      with_signed_in_admin(admin) do
        visit @path

        within "#managed-sites-list" do
          click_on madrid_site.name
        end

        within "#current-site-name" do
          assert has_content?(madrid_site.name)
        end
      end
    end
  end
end
