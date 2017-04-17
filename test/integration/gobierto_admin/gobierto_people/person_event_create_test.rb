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
                fill_in "person_event_title_translations_en", with: "Event Title"
                fill_in "person_event_starts_at", with: "2017-01-01 00:00"
                fill_in "person_event_ends_at", with: "2017-01-01 00:01"
                find("#person_event_description_translations_en", visible: false).set("Event Description")

                click_link "ES"
                fill_in "person_event_title_translations_es", with: "Título Evento"
                find("#person_event_description_translations_es", visible: false).set("Descripción Evento")

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

                within ".person-event-state-radio-buttons" do
                  find("label", text: "Published").trigger('click')
                end

                with_stubbed_s3_file_upload do
                  click_button "Create"
                end
              end

              assert has_message?("Event was successfully created. See the event.")

              within "form.edit_person_event" do
                assert has_field?("person_event_title_translations_en", with: "Event Title")

                assert has_field?("person_event_starts_at", with: "2017-01-01 00:00")
                assert has_field?("person_event_ends_at", with: "2017-01-01 00:01")

                assert_equal(
                  "<div>Event Description</div>",
                  find("#person_event_description_translations_en", visible: false).value
                )

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

                within ".person-event-state-radio-buttons" do
                  with_hidden_elements do
                    assert has_checked_field?("Published")
                  end
                end

                click_link "ES"

                assert has_field?("person_event_title_translations_es", with: "Título Evento")

                assert_equal(
                  "<div>Descripción Evento</div>",
                  find("#person_event_description_translations_es", visible: false).value
                )
              end
            end
          end
        end
      end
    end
  end
end
