# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class ArchiveContributionContainerTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_participation_process_contribution_containers_path(process_id: process)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:sport_city_process)
      end

      def contribution_container
        @contribution_container ||= gobierto_participation_contribution_containers(:children_contributions)
      end

      def test_archive_restore_contribution_container
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#contribution_container-item-#{contribution_container.id}" do
                find("a[data-method='delete']").click
              end

              assert has_message?("Container of contributions archived correctly")

              refute site.contribution_containers.exists?(id: contribution_container.id)

              click_on "Archived elements"

              within "tr#contribution_container-item-#{contribution_container.id}" do
                click_on "Recover element"
              end

              assert has_message?("Container of contributions recovered correctly")
            end
          end
        end
      end
    end
  end
end
