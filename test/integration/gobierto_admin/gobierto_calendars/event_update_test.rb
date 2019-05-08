# frozen_string_literal: true

require "test_helper"
require "support/concerns/gobierto_admin/previewable_item_test_module"

module GobiertoAdmin
  module GobiertoCalendars
    class PersonEventUpdateTest < ActionDispatch::IntegrationTest

      include ::GobiertoAdmin::PreviewableItemTestModule

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

      def external_event
        @external_event ||= gobierto_calendars_events(:richard_published_just_attending)
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

      def preview_test_conf
        {
          item_admin_path: edit_admin_calendars_event_path(event, collection_id: collection),
          item_public_url: event.to_url
        }
      end

      def chosen_start_date
        Time.zone.parse("2017-01-01 00:00")
      end

      def chosen_end_date
        Time.zone.parse("2017-01-01 00:01")
      end

      def test_event_update
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "form.edit_event" do
                fill_in "event_title_translations_en", with: "Event Title"
                fill_in "event_starts_at", with: chosen_start_date
                fill_in "event_ends_at", with: chosen_end_date
                page.execute_script('document.getElementById("event_description_translations_en").value = "Event Description"')

                switch_locale "ES"
                fill_in "event_title_translations_es", with: "Título Evento"
                page.execute_script('document.getElementById("event_description_translations_es").value = "Descripción Evento"')

                within "#person-event-locations" do
                  event.locations.each do |location|
                    within ".dynamic-content-record-wrapper.content-block-record-#{location.id}" do
                      with_hidden_elements do
                        find("a[data-behavior=edit_record]", visible: false).execute_script("this.click()")
                      end

                      fill_in "Place", with: "Location Place"
                      fill_in "Address", with: "Location Address"

                      find("a[data-behavior=add_record]", visible: false).execute_script("this.click()")
                    end
                  end
                end

                within "#person-event-attendees" do
                  event.attendees.each do |attendee|
                    within ".dynamic-content-record-wrapper.content-block-record-#{attendee.id}" do
                      next if attendee.person && attendee.person == person
                      with_hidden_elements do
                        find("a[data-behavior=edit_record]", visible: false).execute_script("this.click()")
                      end

                      select "", from: "Person"
                      fill_in "Name", with: "Attendee Name"
                      fill_in "Position", with: "Attendee Position"

                      find("a[data-behavior=add_record]", visible: false).execute_script("this.click()")
                    end
                  end
                end

                within ".person-event-state-radio-buttons" do
                  find("label", text: "Pending").click
                end

                with_stubbed_s3_file_upload do
                  click_button "Update"
                end
              end

              assert has_message?("Event was successfully updated. See the event.")

              within "form.edit_event" do
                assert has_field?("event_title_translations_en", with: "Event Title")

                assert_equal chosen_start_date.to_s, air_datepicker_field_value(:event_starts_at)
                assert_equal chosen_end_date.to_s, air_datepicker_field_value(:event_ends_at)

                assert_equal(
                  "Event Description",
                  find("#event_description_translations_en", visible: false).value
                )

                within "#person-event-locations .dynamic-content-record-view", match: :first do
                  assert has_selector?(".content-block-record-value", text: "Location Place")
                  assert has_selector?(".content-block-record-value", text: "Location Address")
                end

                assert all(".content-block-record-value").any? { |v| v.text.include?("Attendee Name") }
                assert all(".content-block-record-value").any? { |v| v.text.include?("Attendee Position") }

                within ".person-event-state-radio-buttons" do
                  with_hidden_elements do
                    assert has_checked_field?("Pending")
                  end
                end

                switch_locale "ES"

                assert has_field?("event_title_translations_es", with: "Título Evento")
                assert_equal(
                  "Descripción Evento",
                  find("#event_description_translations_es", visible: false).value
                )
              end
            end
          end
        end
      end

      def test_update_external_event
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit edit_admin_calendars_event_path(external_event, collection_id: collection)

              within "form.edit_event" do
                fill_in "event_title_translations_en", with: "Edited title"

                click_button "Update"
              end

              assert has_message?("Event was successfully updated. See the event.")

              external_event.reload

              assert_equal "justattending", external_event.external_id
            end
          end
        end
      end

    end
  end
end
