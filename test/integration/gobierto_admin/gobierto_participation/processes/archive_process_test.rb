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

      def process_stage_page
        @process_stage_page ||= gobierto_participation_process_stage_pages(:sport_process_information_stage_page)
      end

      def test_archive_restore_process
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              process_stage_page_id = process_stage_page.id
              assert ::GobiertoParticipation::ProcessStagePage.where(id: process_stage_page_id).exists?

              within "#process-item-#{process.id}" do
                find("a[data-method='delete']").click
              end

              assert has_message?("The process has been archived correctly")

              refute ::GobiertoParticipation::ProcessStagePage.where(id: process_stage_page_id).exists?

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
