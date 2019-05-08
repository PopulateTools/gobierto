# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCalendars
    class ArchiveEventTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_participation_process_events_path(process_id: process.id)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def process
        @process ||= gobierto_participation_processes(:gender_violence_process)
      end

      def themes_event
        @themes_event ||= gobierto_calendars_events(:swimming_lessons)
      end

      def test_archive_restore_event
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#person-event-item-#{themes_event.id}" do
                find("a[data-method='delete']").click
              end
              page.driver.browser.switch_to.alert.accept

              assert has_message?("Event was successfully archived")

              click_on "Archived elements"

              within "tr#person-event-item-#{themes_event.id}" do
                click_on "Recover element"
              end
              page.driver.browser.switch_to.alert.accept

              assert has_message?("Event was successfully recovered")
            end
          end
        end
      end

      def test_single_archive_link
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "#person-event-item-#{themes_event.id}" do
                find("a[data-method='delete']").click
              end
              page.driver.browser.switch_to.alert.accept

              assert has_message?("Event was successfully archived")

              assert has_link?("Archived elements")

              click_link "Published events"

              sleep 1

              assert_equal 1, page.all("a").select{ |a| a.text == "Archived elements" }.length
            end
          end
        end
      end
    end
  end
end
