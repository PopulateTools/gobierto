# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Charters
      class DeleteCharterTest < ActionDispatch::IntegrationTest
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

        def charter
          @charter ||= gobierto_citizens_charters_charters(:teleassistance_charter)
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

        def test_delete_charter
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#charter-item-#{charter.id}" do
                find("a[data-method='delete']").click
              end

              assert has_message?("The charter has been correctly archived")

              refute site.charters.exists?(id: charter.id)
            end
          end
        end
      end
    end
  end
end
