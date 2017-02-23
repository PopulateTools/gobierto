require "test_helper"

module GobiertoAdmin
  module GobiertoCms
    class PageIndexTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_cms_pages_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def pages
        @pages ||= site.pages
      end

      def test_pages_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "table.pages-list tbody" do
              assert has_selector?("tr", count: pages.size)

              pages.each do |page|
                assert has_selector?("tr#page-item-#{page.id}")

                within "tr#page-item-#{page.id}" do
                  if page.active?
                    assert has_content?("Published")
                  else
                    assert has_content?("Draft")
                  end
                  assert has_link?("View page")
                end
              end
            end
          end
        end
      end
    end
  end
end
