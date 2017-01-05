require "test_helper"
require "support/file_uploader_helpers"

module GobiertoAdmin
  module GobiertoPeople
    class PersonEventUpdateTest < ActionDispatch::IntegrationTest
      include FileUploaderHelpers

      def setup
        super
        @path = edit_admin_people_person_event_path(person, person_event)
      end

      def person_event
        @person_event ||= gobierto_people_person_events(:richard_approved)
      end

      def person
        @person ||= person_event.person
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_person_event_update
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "form.edit_person_event" do
                fill_in "person_event_title", with: "Event Title"
                fill_in "person_event_starts_at", with: "2017-01-01 00:00:01"
                fill_in "person_event_ends_at", with: "2017-01-01 00:01:01"
                fill_in "person_event_description", with: "Event Description"

                within ".attachment_file_field" do
                  assert has_selector?("a")
                  attach_file "person_event_attachment_file", "test/fixtures/files/gobierto_people/people/person_event/attachment.pdf"
                end

                within "#person-event-locations" do
                  person_event.locations.each do |location|
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
                  person_event.attendees.each do |attendee|
                    within ".dynamic-content-record-wrapper.content-block-record-#{attendee.id}" do
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

                with_stubbed_s3_file_upload do
                  click_button "Update Event"
                end
              end

              assert has_message?("Event was successfully updated")

              within "form.edit_person_event" do
                assert has_field?("person_event_title", with: "Event Title")

                assert has_field?("person_event_starts_at", with: "2017-01-01T00:00:01")
                assert has_field?("person_event_ends_at", with: "2017-01-01T00:01:01")
                assert has_field?("person_event_description", with: "Event Description")

                within ".attachment_file_field" do
                  assert has_selector?("a")
                end

                within "#person-event-locations .dynamic-content-record-view", match: :first do
                  assert has_selector?(".content-block-record-value", text: "Location Place")
                  assert has_selector?(".content-block-record-value", text: "Location Address")
                end

                within "#person-event-attendees .dynamic-content-record-view", match: :first do
                  assert has_selector?(".content-block-record-value", text: "Attendee Name")
                  assert has_selector?(".content-block-record-value", text: "Attendee Charge")
                end
              end
            end
          end
        end
      end
    end
  end
end
