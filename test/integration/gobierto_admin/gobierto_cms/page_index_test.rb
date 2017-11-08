# frozen_string_literal: true

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

      def collections
        @collections ||= site.collections.where(item_type: '["GobiertoCms::Page", "GobiertoCms:New"]')
      end

      def test_collections_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "table tbody" do
              collections.each do |collection|
                assert has_selector?("tr#collection-item-#{collection.id}")

                within "tr#collection-item-#{collection.id}" do
                  assert has_link?("View collection")
                end
              end
            end
          end
        end
      end
    end
  end
end
