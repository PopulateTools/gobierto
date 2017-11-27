# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCalendars
    class EventCreateTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = new_admin_calendars_event_path(collection_id: collection)
      end

      def collection
        @collection ||= person.events_collection
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def attendee
        @attendee ||= gobierto_people_people(:tamara)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_event_create
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "form.new_event" do
                fill_in "event_title_translations_en", with: "Event Title"
                fill_in "event_starts_at", with: "2017-01-01 00:00"
                fill_in "event_ends_at", with: "2017-01-01 00:01"
                find("#event_description_translations_en", visible: false).set("Event Description")

                click_link "ES"
                fill_in "event_title_translations_es", with: "Título Evento"
                find("#event_description_translations_es", visible: false).set("Descripción Evento")

                within "#person-event-locations" do
                  find("a[data-behavior=add_child]").click

                  within ".cloned-dynamic-content-record-wrapper" do
                    fill_in "Place", with: "Location Place"
                    fill_in "Address", with: "Location Address"

                    find("a[data-behavior=add_record]").click
                  end
                end

                within "#person-event-attendees" do
                  find("a[data-behavior=add_child]").click

                  within all(".cloned-dynamic-content-record-wrapper")[0] do
                    select attendee.name, from: "Person"
                    fill_in "Name", with: ""
                    fill_in "Charge", with: ""

                    find("a[data-behavior=add_record]").click
                  end
                end

                within ".person-event-state-radio-buttons" do
                  find("label", text: "Published").trigger("click")
                end

                with_stubbed_s3_file_upload do
                  click_button "Create"
                end
              end

              assert has_message?("Event was successfully created. See the event.")

              within "form.edit_event" do
                assert has_field?("event_title_translations_en", with: "Event Title")

                assert has_field?("event_starts_at", with: "2017-01-01 00:00")
                assert has_field?("event_ends_at", with: "2017-01-01 00:01")

                assert_equal(
                  "<div>Event Description</div>",
                  find("#event_description_translations_en", visible: false).value
                )

                within "#person-event-locations .dynamic-content-record-view" do
                  assert has_selector?(".content-block-record-value", text: "Location Place")
                  assert has_selector?(".content-block-record-value", text: "Location Address")
                end

                assert all(".content-block-record-value").any? { |v| v.text.include?(attendee.name) }

                within ".person-event-state-radio-buttons" do
                  with_hidden_elements do
                    assert has_checked_field?("Published")
                  end
                end

                click_link "ES"

                assert has_field?("event_title_translations_es", with: "Título Evento")

                assert_equal(
                  "<div>Descripción Evento</div>",
                  find("#event_description_translations_es", visible: false).value
                )
              end
            end
          end
        end
      end
    end
  end
end
