# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class ArchivePollTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_participation_process_polls_path(process_id: process)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:commission_for_carnival_festivities)
      end

      def poll
        @poll ||= gobierto_participation_polls(:pedestrianization_published)
      end

      def test_archive_restore_poll
        with(js: true) do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#poll-item-#{poll.id}" do
                find("a[data-method='delete']").click
              end

              assert has_message?("Poll archived successfully")

              click_on "Archived elements"

              within "tr#poll-item-#{poll.id}" do
                click_on "Recover element"
              end

              assert has_message?("Poll recovered successfully")
            end
          end
        end
      end
    end
  end
end
