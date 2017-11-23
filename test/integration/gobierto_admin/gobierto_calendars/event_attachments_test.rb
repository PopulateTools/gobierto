# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCalendars
    class EventAttachmentsTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = edit_admin_calendars_event_path(event, collection_id: collection)
      end

      def collection
        @collection ||= person.events_collection
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def event
        @event ||= gobierto_calendars_events(:richard_published)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_list_page_attachments
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link event.title

              refute has_content?("XLSX Attachment Name")
              page.find("a.show-files").trigger("click")
              assert has_content?("XLSX Attachment Name")
            end
          end
        end
      end

      def test_list_site_attachments
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              click_link event.title

              page.find("#show-modal").trigger("click")
              assert has_content?("XLSX Attachment Name")
              assert has_content?("PDF Attachment Name")
            end
          end
        end
      end
    end
  end
end
