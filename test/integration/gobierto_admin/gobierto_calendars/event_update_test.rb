# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCalendars
    class PersonEventUpdateTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = edit_admin_calendars_event_path(event, collection_id: collection)
      end

      def collection
        @collection ||= person.events_collection
      end

      def event
        @event ||= gobierto_calendars_events(:richard_published)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_event_update
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "form.edit_event" do
                fill_in "event_title_translations_en", with: "Event Title"
                fill_in "event_starts_at", with: "2017-01-01 00:00"
                fill_in "event_ends_at", with: "2017-01-01 00:01"
                find("#event_description_translations_en", visible: false).set("Event Description")

                click_link "ES"
                fill_in "event_title_translations_es", with: "Título Evento"
                find("#event_description_translations_es", visible: false).set("Descripción Evento")

                within "#person-event-locations" do
                  event.locations.each do |location|
                    within ".dynamic-content-record-wrapper.content-block-record-#{location.id}" do
                      with_hidden_elements do
                        find("a[data-behavior=edit_record]").trigger("click")
                      end

                      fill_in "Place", with: "Location Place"
                      fill_in "Address", with: "Location Address"

                      find("a[data-behavior=add_record]").click
                    end
                  end
                end

                within "#person-event-attendees" do
                  event.attendees.each do |attendee|
                    within ".dynamic-content-record-wrapper.content-block-record-#{attendee.id}" do
                      next if attendee.person && attendee.person == person
                      with_hidden_elements do
                        find("a[data-behavior=edit_record]").trigger("click")
                      end

                      select "", from: "Person"
                      fill_in "Name", with: "Attendee Name"
                      fill_in "Charge", with: "Attendee Charge"

                      find("a[data-behavior=add_record]").click
                    end
                  end
                end

                within ".person-event-state-radio-buttons" do
                  find("label", text: "Pending").click
                end

                scroll_to_top

                with_stubbed_s3_file_upload do
                  click_button "Update"
                end
              end

              assert has_message?("Event was successfully updated. See the event.")

              within "form.edit_event" do
                assert has_field?("event_title_translations_en", with: "Event Title")

                assert has_field?("event_starts_at", with: "2017-01-01 00:00")
                assert has_field?("event_ends_at", with: "2017-01-01 00:01")
                assert_equal(
                  "<div>Event Description</div>",
                  find("#event_description_translations_en", visible: false).value
                )

                within "#person-event-locations .dynamic-content-record-view", match: :first do
                  assert has_selector?(".content-block-record-value", text: "Location Place")
                  assert has_selector?(".content-block-record-value", text: "Location Address")
                end

                assert all(".content-block-record-value").any? { |v| v.text.include?("Attendee Name") }
                assert all(".content-block-record-value").any? { |v| v.text.include?("Attendee Charge") }

                within ".person-event-state-radio-buttons" do
                  with_hidden_elements do
                    assert has_checked_field?("Pending")
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
