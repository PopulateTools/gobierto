# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Commitments
      class CommitmentsIndexTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_citizens_charters_charter_commitments_path(charter)
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

        def commitments
          @commitments ||= charter.commitments
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

        def test_commitments_index
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "table tbody" do
                assert has_selector?("tr", count: commitments.size)

                commitments.each do |commitment|
                  assert has_selector?("tr#commitment-item-#{commitment.id}")

                  within "tr#commitment-item-#{commitment.id}" do
                    assert has_link?(commitment.title)
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
