require 'test_helper'

module GobiertoCms
  class PageIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_cms_pages_path
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def site
      @site ||= sites(:madrid)
    end

    def pages
      @pages ||= site.pages.active
    end

    def test_pages_index
      with_signed_in_admin(admin) do
        with_current_site(site) do
          visit @path

          pages.each do |page|
            assert has_link?(page.title)
          end
        end
      end
    end
  end
end
