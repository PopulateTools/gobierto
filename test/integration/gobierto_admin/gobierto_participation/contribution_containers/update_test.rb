# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/previewable_item_test_module"

module GobiertoAdmin
  module GobiertoParticipation
    class UpdateContributionContainerTest < ActionDispatch::IntegrationTest

      include ::GobiertoAdmin::PreviewableItemTestModule

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:commission_for_carnival_festivities)
      end

      def contribution_container
        @contribution_container ||= begin
          gobierto_participation_contribution_containers(:bowling_group_contributions_future_draft)
        end
      end

      def preview_test_conf
        {
          item_admin_path: edit_admin_participation_process_contribution_container_path(
            contribution_container,
            process_id: process.id
          ),
          item_public_url: contribution_container.to_url
        }
      end

    end
  end
end
