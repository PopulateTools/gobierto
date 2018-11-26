# frozen_string_literal: true

require "test_helper"

module GobiertoCitizensCharters
  module GobiertoAdmin
    class DeleteCommitmentTest < ActionDispatch::IntegrationTest

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

      def commitment
        @commitment ||= gobierto_citizens_charters_commitments(:devices_operation)
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

      def test_delete_commitment
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "#commitment-item-#{commitment.id}" do
              find("a[data-method='delete']").click
            end

            assert has_message?("The commitment has been correctly deleted")

            refute site.commitments.exists?(id: commitment.id)
          end
        end

        activity = Activity.last
        assert_equal charter, activity.subject
        assert_equal admin, activity.author
        assert_equal site.id, activity.site_id
        assert_equal "gobierto_citizens_charters.charter.commitment_archived", activity.action
      end
    end
  end
end
