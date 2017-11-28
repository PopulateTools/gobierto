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
        'richard@google-calendar.com'
      end

      def ibm_notes_configuration
        @ibm_notes_configuration ||= {
          ibm_notes_usr: 'ibm-notes-usr',
          ibm_notes_pwd: 'ibm-notes-pwd',
          ibm_notes_url: 'http://ibm-calendar/richard'
        }
      end

      def microsoft_exchange_configuration
        @microsoft_exchange_configuration ||= {
          microsoft_exchange_usr: 'microsoft-exchange-usr',
          microsoft_exchange_pwd: 'microsoft-exchange-pwd',
          microsoft_exchange_url: 'http://me-calendar/richard'
        }
      end

      def google_calendar_configuration
        @google_calendar_configuration ||= {
          google_calendar_credentials: 'person_credentials'
        }
      end

      def setup
        super
        clear_calendar_configurations
        @person_events_path = admin_people_person_events_path(person)

        ## Mocks
        calendar1 = mock
        calendar1.stubs(id: google_calendar_id, primary?: true, summary: 'Calendar 1')

        calendar2 = mock
        calendar2.stubs(id: 2, primary?: false, summary: 'Calendar 2')

        calendar3 = mock
        calendar3.stubs(id: 3, primary?: false, summary: 'Calendar 3')

        calendars_mock = mock
        calendars_mock.stubs(:calendars).returns([calendar1, calendar2, calendar3])
        ::GobiertoPeople::GoogleCalendar::CalendarIntegration.stubs(:new).returns(calendars_mock)

        setup_authorizable_resource_test(gobierto_admin_admins(:steve), @person_events_path)
       end

      def person
        gobierto_people_people(:richard)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def tony
        @tony ||= gobierto_admin_admins(:tony)
      end
      alias regular_admin_with_permissions tony

      def steve
        @steve ||= gobierto_admin_admins(:steve)
      end
      alias regular_admin_without_permissions steve

      def site
        @site ||= sites(:madrid)
      end

      def encrypted_setting_placeholder
        ::GobiertoAdmin::GobiertoCalendars::CalendarConfigurationForm::ENCRYPTED_SETTING_PLACEHOLDER
      end

      def test_configure_ibm_notes_integration
        configure_ibm_notes_calendar_integration(
          collection: person.calendar,
          data: ibm_notes_configuration
        )

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @person_events_path

            click_link 'Agenda'
            click_link 'Configuration'

            assert has_field?('calendar_configuration[ibm_notes_usr]', with: 'ibm-notes-usr')
            assert has_field?('calendar_configuration[ibm_notes_pwd]', with: encrypted_setting_placeholder)
            assert has_field?('calendar_configuration[ibm_notes_url]', with: 'http://ibm-calendar/richard')

            # set calendar configuration
            select 'IBM Notes', from: 'calendar_configuration_calendar_integration'

            fill_in 'calendar_configuration_ibm_notes_usr', with: 'new-ibm-notes-usr'
            fill_in 'calendar_configuration_ibm_notes_pwd', with: 'new-ibm-notes-pwd'
            fill_in 'calendar_configuration_ibm_notes_url', with: 'http://ibm-calendar/richard/new'

            click_button 'Update'

            assert has_message?("Settings updated successfully")

            # assert data displays correctly in the UI
            assert has_field?('calendar_configuration[ibm_notes_usr]', with: 'new-ibm-notes-usr')
            assert has_field?('calendar_configuration[ibm_notes_pwd]', with: encrypted_setting_placeholder)
            assert has_field?('calendar_configuration[ibm_notes_url]', with: 'http://ibm-calendar/richard/new')

            calendar_configuration = person.calendar_configuration.reload

            # assert data was stored in the DB
            assert_equal 'new-ibm-notes-usr', calendar_configuration.data['ibm_notes_usr']
            assert_equal 'new-ibm-notes-pwd', SecretAttribute.decrypt(calendar_configuration.data['ibm_notes_pwd'])
            assert_equal 'http://ibm-calendar/richard/new', calendar_configuration.data['ibm_notes_url']

            # clear calendar configuration
            assert_enqueued_with(job: ::GobiertoPeople::ClearImportedPersonEventsJob, args: [person], queue: 'default') do
              check 'calendar_configuration[clear_calendar_configuration]'
              click_button 'Update'
            end

            # assert data is not displayed in the UI
            assert_nil find_field('calendar_configuration_ibm_notes_usr', visible: false).value
            assert_nil find_field('calendar_configuration_ibm_notes_pwd', visible: false).value
            assert_nil find_field('calendar_configuration_ibm_notes_url', visible: false).value

            # assert data was removed from the DB
            calendar = person.calendar.reload

            assert_nil calendar.calendar_configuration
          end
        end
      end

      def test_configure_new_google_calendar_integration
        with_javascript do
          with_signed_in_admin(admin) do
            with_current_site(site) do
              visit @person_events_path

              click_link 'Agenda'
              click_link 'Configuration'

              select 'Google Calendar', from: 'calendar_configuration_calendar_integration'

              assert has_field?('google_calendar_invitation_url')
            end
          end
        end
      end

      def test_reconfigure_existing_google_calendar_integration
        configure_google_calendar_integration(
          collection: person.calendar,
          data: google_calendar_configuration
        )

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @person_events_path

            click_link 'Agenda'
            click_link 'Configuration'

            refute has_field?('google_calendar_invitation_url')

            refute has_checked_field?('Calendar 1')
            refute has_checked_field?('Calendar 2')
            refute has_checked_field?('Calendar 3')

            check 'Calendar 1'

            click_button 'Update'

            assert has_checked_field?('Calendar 1')
            refute has_checked_field?('Calendar 2')
            refute has_checked_field?('Calendar 3')

            # clear calendar configuration
            assert_enqueued_with(job: ::GobiertoPeople::ClearImportedPersonEventsJob, args: [person], queue: 'default') do
              check 'calendar_configuration[clear_calendar_configuration]'
              click_button 'Update'
            end

            # assert invitation URL is displayed again
            assert has_field?('google_calendar_invitation_url', visible: false)

            # assert data was removed from the DB
            calendar = person.calendar.reload
            assert_nil calendar.calendar_configuration
          end
        end
      end

      def test_configure_microsoft_exchange_integration
        configure_microsoft_exchange_calendar_integration(
          collection: person.calendar,
          data: microsoft_exchange_configuration
        )

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @person_events_path

            click_link 'Agenda'
            click_link 'Configuration'

            assert has_field?('calendar_configuration[microsoft_exchange_usr]', with: 'microsoft-exchange-usr')
            assert has_field?('calendar_configuration[microsoft_exchange_pwd]', with: encrypted_setting_placeholder)
            assert has_field?('calendar_configuration[microsoft_exchange_url]', with: 'http://me-calendar/richard')

            # set calendar configuration
            fill_in 'calendar_configuration_microsoft_exchange_usr', with: 'new-microsoft-exchange-usr'
            fill_in 'calendar_configuration_microsoft_exchange_pwd', with: 'new-microsoft-exchange-pwd'
            fill_in 'calendar_configuration_microsoft_exchange_url', with: 'http://me-calendar/richard/new'

            click_button 'Update'

            assert has_field?('calendar_configuration[microsoft_exchange_usr]', with: 'new-microsoft-exchange-usr')
            assert has_field?('calendar_configuration[microsoft_exchange_pwd]', with: encrypted_setting_placeholder)
            assert has_field?('calendar_configuration[microsoft_exchange_url]', with: 'http://me-calendar/richard/new')

            calendar_configuration = person.calendar_configuration.reload

            assert_equal 'new-microsoft-exchange-usr', calendar_configuration.data['microsoft_exchange_usr']
            assert_equal 'new-microsoft-exchange-pwd', SecretAttribute.decrypt(calendar_configuration.data['microsoft_exchange_pwd'])
            assert_equal 'http://me-calendar/richard/new', calendar_configuration.data['microsoft_exchange_url']

            # clear calendar configuration
            assert_enqueued_with(job: ::GobiertoPeople::ClearImportedPersonEventsJob, args: [person], queue: 'default') do
              check 'calendar_configuration[clear_calendar_configuration]'
              click_button 'Update'
            end

            # assert data is not displayed in the UI
            assert_nil find_field('calendar_configuration_microsoft_exchange_url', visible: false).value
            assert_nil find_field('calendar_configuration_microsoft_exchange_usr', visible: false).value
            assert_nil find_field('calendar_configuration_microsoft_exchange_pwd', visible: false).value

            # assert data was removed from the DB
            calendar = person.calendar.reload

            assert_nil calendar.calendar_configuration
          end
        end
      end

      def test_save_incomplete_calendar_configuration
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @person_events_path

            click_link 'Agenda'
            click_link 'Configuration'

            select "IBM Notes", from: "calendar_configuration_calendar_integration"

            click_button "Update"

            assert has_text?("Account can't be blank")
            assert has_text?("Password can't be blank")
            assert has_text?("URL can't be blank")

            select "Microsoft Exchange", from: 'calendar_configuration_calendar_integration'

            click_button "Update"

            assert has_text?("Account can't be blank")
            assert has_text?("Password can't be blank")
            assert has_text?("URL can't be blank")
          end
        end
      end

      def test_regular_admin_manage_without_permissions
        with_signed_in_admin(regular_admin_without_permissions) do
          with_current_site(site) do
            visit edit_admin_calendars_configuration_path(person.calendar)

            assert has_content?('You do not have enough permissions to perform this action')
          end
        end
      end

      def test_regular_admin_manage_with_permissions
        with_signed_in_admin(regular_admin_with_permissions) do
          with_current_site(site) do
            visit edit_admin_calendars_configuration_path(person.calendar)

            refute has_content?('You do not have enough permissions to perform this action')
          end
        end
      end

    end
  end
end
