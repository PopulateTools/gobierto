# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  module GobiertoCommon
    module ContentBlocks
      class ContentBlockDeleteTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_common_content_block_path(content_block.id)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def regular_admin
          @regular_admin ||= gobierto_admin_admins(:tony)
        end

        def site
          @site ||= sites(:madrid)
        end

        def content_block
          @content_block ||= gobierto_common_content_blocks(:contact_methods)
        end

        def test_content_block_delete
          with_signed_in_admin(admin) do
            with_current_site(site) do
              page.driver.submit :delete, @path, {}

              assert has_message?('Content block was successfully deleted')
            end
          end
        end

        def test_content_block_delete
          with_signed_in_admin(regular_admin) do
            with_current_site(site) do
              page.driver.submit :delete, @path, {}

              assert has_message?('You are not authorized to perform this action')
            end
          end
        end
      end
    end
  end
end
