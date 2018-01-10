# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class ArchiveProcessTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_participation_path
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

      def test_archive_restore_process
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#process-item-#{process.id}" do
                find("a[data-method='delete']").click
              end

              assert has_message?("The process has been archived correctly")

              click_on "Archived elements"

              within "div#archived-list" do
                within "tr#process-item-#{process.id}" do
                  click_on "Recover element"
                end
              end

              assert has_message?("The process has been recovered correctly")
            end
          end
        end
      end
    end
  end
end
