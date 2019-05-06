# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/previewable_item_test_module"

module GobiertoAdmin
  module GobiertoParticipation
    class ProcessEventsTest < ActionDispatch::IntegrationTest

      include ::GobiertoAdmin::PreviewableItemTestModule

      def setup
        super
        collection.append(event)
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

      def collection
        @collection ||= gobierto_common_collections(:gender_violence_process_calendar)
      end

      def event
        @event ||= gobierto_calendars_events(:reading_club)
      end

      def preview_test_conf
        {
          item_admin_path: edit_admin_calendars_event_path(event, collection_id: collection.id),
          item_public_url: event.to_url
        }
      end

      def test_events
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_participation_process_path(process)

            within ".tabs" do
              click_link "Agenda"
            end

            assert has_content?(event.title)
          end
        end
      end

      def test_create_event
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit edit_admin_participation_process_path(process)

              within ".tabs" do
                click_link "Agenda"
              end

              click_link "New event"

              assert has_selector?("h1", text: process.title)

              fill_in "event_title_translations_en", with: "Event Title"
              fill_in "event_starts_at", with: "2017-01-01 00:00"
              fill_in "event_ends_at", with: "2017-01-01 00:01"
              find("#event_description_translations_en", visible: false).set("Event Description")

              click_button "Create"

              assert has_message?("Event was successfully created.")

              assert has_selector?("h1", text: process.title)

              within ".tabs" do
                click_link "Agenda"
              end

              assert has_content?("Event Title")
            end
          end
        end
      end

      def test_edit_event
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit edit_admin_participation_process_path(process)

              within ".tabs" do
                click_link "Agenda"
              end

              click_link event.title

              assert has_selector?("h1", text: process.title)

              fill_in "event_title_translations_en", with: "My event updated"
              click_button "Update"

              assert has_message?("Event was successfully updated")

              assert has_selector?("h1", text: process.title)

              within ".tabs" do
                click_link "Agenda"
              end

              assert has_content?("My event updated")
              assert has_no_content?(event.title)
            end
          end
        end
      end

      def test_preview_calendar
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit admin_participation_process_events_path(process)

            assert preview_link_excludes_token?
            click_preview_link

            assert has_content? "Diary for #{process.title}"

            process.draft!

            visit admin_participation_process_events_path(process)

            assert preview_link_includes_token?
            click_preview_link

            assert has_content? "Diary for #{process.title}"
          end
        end
      end

    end
  end
end
