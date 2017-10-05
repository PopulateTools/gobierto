# frozen_string_literal: true

require "test_helper"
require "support/calendar_integration_helpers"
require "support/concerns/gobierto_admin/authorizable_resource_test_module"

module GobiertoAdmin
  module GobiertoPeople
    class PersonCalendarConfigurationTest < ActionDispatch::IntegrationTest

      include ::CalendarIntegrationHelpers
      include ::GobiertoAdmin::AuthorizableResourceTestModule

      def google_calendar_id
        "richard@google-calendar.com"
      end

      def setup
        super
        @person_events_path = admin_people_person_events_path(person)

        ## Mocks
        calendar1 = mock
        calendar1.stubs(id: google_calendar_id, primary?: true, summary: "Calendar 1")

        calendar2 = mock
        calendar2.stubs(id: 2, primary?: false, summary: "Calendar 2")

        calendar3 = mock
        calendar3.stubs(id: 3, primary?: false, summary: "Calendar 3")

        calendars_mock = mock
        calendars_mock.stubs(:calendars).returns([calendar1, calendar2, calendar3])
        ::GobiertoPeople::GoogleCalendar::CalendarIntegration.stubs(:new).returns(calendars_mock)

        setup_authorizable_resource_test(gobierto_admin_admins(:steve), @person_events_path)
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

      def test_person_calendar_configuration_for_ibm_notes
        with_signed_in_admin(admin) do
          with_current_site(site) do
            activate_ibm_notes_calendar_integration(site)
            set_ibm_notes_calendar_endpoint(person, "http://calendar/richard")

            visit @person_events_path

            click_link "Agenda"
            click_link "Configuration"

            assert has_field?("calendar_configuration[ibm_notes_url]", with: "http://calendar/richard")

            fill_in "calendar_configuration_ibm_notes_url", with: "http://calendar/richard/new"

            click_button "Update"

            assert has_field?("calendar_configuration[ibm_notes_url]", with: "http://calendar/richard/new")
            refute has_field?("calendar_configuration[ibm_notes_url]", with: "http://calendar/richard")

            assert_enqueued_with(job: ::GobiertoPeople::ClearImportedPersonEventsJob, args: [person], queue: "default") do
              fill_in "calendar_configuration_ibm_notes_url", with: ""
              click_button "Update"
            end

            assert has_field?("calendar_configuration[ibm_notes_url]")
          end
        end
      end

      def test_person_calendar_configuration_for_google_calendar
        with_signed_in_admin(admin) do
          with_current_site(site) do
            activate_google_calendar_calendar_integration(site)

            visit @person_events_path

            click_link "Agenda"
            click_link "Configuration"

            assert has_field?("google_calendar_invitation_url")
          end
        end
      end

      def test_person_calendar_configuration_for_google_calendar_configured_account
        with_signed_in_admin(admin) do
          with_current_site(site) do
            activate_google_calendar_calendar_integration(site)
            configure_google_calendar_integration(person, "google_calendar_credentials" => "person credentials")

            visit @person_events_path

            click_link "Agenda"
            click_link "Configuration"

            refute has_field?("google_calendar_invitation_url")
            assert has_field?("calendar_configuration[clear_google_calendar_configuration]")

            refute has_checked_field?("Calendar 1")
            refute has_checked_field?("Calendar 2")
            refute has_checked_field?("Calendar 3")

            check "Calendar 1"

            click_button "Update"

            assert has_checked_field?("Calendar 1")
            refute has_checked_field?("Calendar 2")
            refute has_checked_field?("Calendar 3")

            assert_enqueued_with(job: ::GobiertoPeople::ClearImportedPersonEventsJob, args: [person], queue: "default") do
              check "calendar_configuration[clear_google_calendar_configuration]"
              click_button "Update"
            end

            assert has_field?("google_calendar_invitation_url")
            refute has_field?("calendar_configuration[clear_google_calendar_configuration]")
          end
        end
      end
    end
  end
end
