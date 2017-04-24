require 'test_helper'
require 'support/calendar_integration_helpers'

module GobiertoAdmin
  module GobiertoPeople
    class PersonEventsIndexTest < ActionDispatch::IntegrationTest

      include ::CalendarIntegrationHelpers

      def setup
        super
        @person_events_path = admin_people_person_events_path(person)
        activate_calendar_integration(person.site)
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

      def test_read_person_calendar_configuration
        activate_calendar_integration(site)

        with_signed_in_admin(admin) do
          with_current_site(site) do
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

    end
  end
end
