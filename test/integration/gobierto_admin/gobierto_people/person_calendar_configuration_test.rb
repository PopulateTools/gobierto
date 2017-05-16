require 'test_helper'
require 'support/calendar_integration_helpers'

module GobiertoAdmin
  module GobiertoPeople
    class PersonCalendarConfigurationTest < ActionDispatch::IntegrationTest

      include ::CalendarIntegrationHelpers

      def setup
        super
        @person_events_path = admin_people_person_events_path(person)
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
            set_ibm_notes_calendar_endpoint(person, 'http://calendar/richard')

            visit @person_events_path

            click_link 'Agenda'
            click_link 'Configuration'

            assert has_field?('calendar_configuration[ibm_notes_url]', with: 'http://calendar/richard')

            fill_in 'calendar_configuration_ibm_notes_url', with: 'http://calendar/richard/new'

            click_button 'Update'

            assert has_field?('calendar_configuration[ibm_notes_url]', with: 'http://calendar/richard/new')
            refute has_field?('calendar_configuration[ibm_notes_url]', with: 'http://calendar/richard')
          end
        end
      end

      def test_person_calendar_configuration_for_google_calendar
        with_signed_in_admin(admin) do
          with_current_site(site) do
            activate_google_calendar_calendar_integration(site)

            visit @person_events_path

            click_link 'Agenda'
            click_link 'Configuration'

            assert has_field?('google_calendar_invitation_url')
          end
        end
      end

      def test_person_calendar_configuration_for_google_calendar_configured_account
        with_signed_in_admin(admin) do
          with_current_site(site) do
            activate_google_calendar_calendar_integration(site)
            configure_google_calendar_integration(person, {
              'google_calendar_credentials' => 'person credentials'
            })

            visit @person_events_path

            click_link 'Agenda'
            click_link 'Configuration'

            refute has_field?('google_calendar_invitation_url')
            assert has_field?('calendar_configuration[clear_google_calendar_configuration]')
          end
        end
      end


    end
  end
end
