# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Charters
      class ChartersIndexTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_citizens_charters_charters_path
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def unauthorized_admin
          @unauthorized_admin ||= gobierto_admin_admins(:steve)
        end

        def site
          @site ||= sites(:madrid)
        end

        def charters
          @charters ||= site.charters
        end

        def test_permissions
          with_signed_in_admin(unauthorized_admin) do
            with_current_site(site) do
              visit @path
              assert has_content?("You are not authorized to perform this action")
              assert_equal admin_root_path, current_path
            end
          end
        end

        def test_charters_index
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "table tbody" do
                assert has_selector?("tr", count: charters.size)

                charters.each do |charter|
                  assert has_selector?("tr#charter-item-#{ charter.id }")

                  within "tr#charter-item-#{ charter.id }" do
                    assert has_link?(charter.title)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
