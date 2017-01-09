require "test_helper"
require "support/file_uploader_helpers"

module GobiertoAdmin
  module GobiertoPeople
    class PersonEventCreateTest < ActionDispatch::IntegrationTest
      include FileUploaderHelpers

      def setup
        super
        @path = new_admin_people_person_event_path(person)
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

      def test_person_event_create
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @path

              within "form.new_person_event" do
                fill_in "person_event_title", with: "Event Title"
                fill_in "person_event_starts_at", with: "2017-01-01 00:00"
                fill_in "person_event_ends_at", with: "2017-01-01 00:01"
                fill_in "person_event_description", with: "Event Description"

                within ".attachment_file_field" do
                  refute has_selector?("a")
                  attach_file "person_event_attachment_file", "test/fixtures/files/gobierto_people/people/person_event/attachment.pdf"
                end

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

                  within ".cloned-dynamic-content-record-wrapper" do
                    select attendee.name, from: "Person"
                    fill_in "Name", with: ""
                    fill_in "Charge", with: ""

                    find("a[data-behavior=add_record]").click
                  end
                end

                with_stubbed_s3_file_upload do
                  click_button "Create Event"
                end
              end

              assert has_message?("Event was successfully created")

              within "form.edit_person_event" do
                assert has_field?("person_event_title", with: "Event Title")

                assert has_field?("person_event_starts_at", with: "2017-01-01 00:00")
                assert has_field?("person_event_ends_at", with: "2017-01-01 00:01")
                assert has_field?("person_event_description", with: "Event Description")

                within ".attachment_file_field" do
                  assert has_selector?("a")
                end

                within "#person-event-locations .dynamic-content-record-view" do
                  assert has_selector?(".content-block-record-value", text: "Location Place")
                  assert has_selector?(".content-block-record-value", text: "Location Address")
                end

                within "#person-event-attendees .dynamic-content-record-view" do
                  assert has_selector?(".content-block-record-value", text: attendee.name)
                end
              end
            end
          end
        end
      end
    end
  end
end
