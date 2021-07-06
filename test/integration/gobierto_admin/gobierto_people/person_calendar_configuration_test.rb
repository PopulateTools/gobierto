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
          ibm_notes_url: 'http://ibm-calendar/richard',
          without_description: '0'
        }
      end

      def microsoft_exchange_configuration
        @microsoft_exchange_configuration ||= {
          microsoft_exchange_usr: 'microsoft-exchange-usr',
          microsoft_exchange_pwd: 'microsoft-exchange-pwd',
          microsoft_exchange_url: 'http://me-calendar/richard',
          without_description: '0'
        }
      end

      def google_calendar_configuration
        @google_calendar_configuration ||= {
          google_calendar_credentials: 'person_credentials',
          without_description: '0'
        }
      end

      def setup
        super
        clear_calendar_configurations
        @person_events_path = admin_calendars_events_path(collection_id: person.events_collection.id)

        ## Mocks
        calendar1 = mock
        calendar1.stubs(id: google_calendar_id, primary?: true, summary: 'Calendar 1')

        creator_event2 = mock
        creator_event2.stubs(email: google_calendar_id)

        date1 = mock
        date1.stubs(date_time: 3.minutes.from_now)
        date2 = mock
        date2.stubs(date_time: 1.hour.from_now)

        # Single event, organized by richard, with two attendees
        event2 = mock
        event2.stubs(visibility: nil, location: nil, creator: creator_event2, recurrence: nil, id: "event2",
                     summary: "@ Event 2", start: date1, end: date2, attendees: [], description: "Event 2 description")

        calendar_1_items_response = mock
        calendar_1_items_response.stubs(:items).returns([event2])

        calendar2 = mock
        calendar2.stubs(id: 2, primary?: false, summary: 'Calendar 2')

        calendar3 = mock
        calendar3.stubs(id: 3, primary?: false, summary: 'Calendar 3')

        calendar_items_response = mock
        calendar_items_response.stubs(:items).returns([calendar1, calendar2, calendar3])

        client_options = mock
        client_options.stubs(:application_name=).returns(true)

        ::Google::Apis::CalendarV3::CalendarService.any_instance.stubs(:list_calendar_lists).returns(calendar_items_response)
        ::Google::Apis::CalendarV3::CalendarService.any_instance.stubs(:list_events).with(calendar1.id, instance_of(Hash)).returns(calendar_1_items_response)
        ::Google::Apis::CalendarV3::CalendarService.any_instance.stubs(:client_options).returns(client_options)
        ::Google::Apis::CalendarV3::CalendarService.any_instance.stubs(:authorization=).returns(true)
        ::Google::Auth::UserAuthorizer.any_instance.stubs(:get_credentials).returns(true)

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

      def test_sync_calendars_generates_a_site_activity
        Activity.where(subject: person, action:  "admin_gobierto_calendars.calendars_synchronized").destroy_all
        configure_google_calendar_integration(
          collection: person.calendar,
          data: google_calendar_configuration
        )

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @person_events_path

            click_link 'Agenda'
            click_link 'Configuration'

            check 'Calendar 1'

            click_button 'Update'

            assert has_link?('Sync now')
            assert has_no_text? 'Last sync:'
            assert_difference 'Activity.where(subject: person, action: "admin_gobierto_calendars.calendars_synchronized").count', 1 do
              click_link 'Sync now'
            end

            assert has_text? 'Last sync: less than a minute ago'

            refute_nil person.events.find_by external_id: "event2"
          end
        end
      end

      def test_sync_calendars_without_description
        configure_google_calendar_integration(
          collection: person.calendar,
          data: google_calendar_configuration
        )

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @person_events_path

            click_link 'Agenda'
            click_link 'Configuration'

            check 'Calendar 1'
            check "Don't import event description"

            click_button 'Update'

            click_link 'Sync now'

            assert has_text? 'Last sync: less than a minute ago'

            event = person.events.find_by external_id: "event2"
            refute_nil event
            assert_nil event.description

            check 'Calendar 1'
            uncheck "Don't import event description"

            click_button 'Update'
            click_link 'Sync now'
            assert has_text? 'Last sync: less than a minute ago'

            event = person.events.find_by external_id: "event2"
            refute_nil event
            assert_equal "Event 2 description", event.description
          end
        end
      end

      def test_sync_calendars_with_default_locale
        configure_google_calendar_integration(
          collection: person.calendar,
          data: google_calendar_configuration
        )

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @person_events_path

            click_link 'Agenda'
            click_link 'Configuration'

            check 'Calendar 1'

            click_button 'Update'

            site.configuration.default_locale = 'es'
            site.save

            click_link 'Sync now'

            assert has_text? 'Last sync: less than a minute ago'

            event = person.events.find_by external_id: "event2"
            assert_equal event.title_translations['es'], event.title
            assert_equal event.description_translations['es'], event.description

            rest_of_locales = I18n.available_locales - ["es".to_sym]

            rest_of_locales.each do |locale|
              assert_nil event.title_translations[locale.to_s]
              assert_nil event.description_translations[locale.to_s]
            end

            site.configuration.default_locale = 'ca'
            site.save

            click_link 'Sync now'

            assert has_text? 'Last sync: less than a minute ago'

            event = person.events.find_by external_id: "event2"
            assert_equal event.title_translations['ca'], event.title
            assert_equal event.description_translations['ca'], event.description

            rest_of_locales = I18n.available_locales - ["ca".to_sym]

            rest_of_locales.each do |locale|
              assert_nil event.title_translations[locale.to_s]
              assert_nil event.description_translations[locale.to_s]
            end
          end
        end
      end

      def test_sync_calendars_errors
        configure_ibm_notes_calendar_integration(
          collection: person.calendar,
          data: ibm_notes_configuration
        )

        ::GobiertoPeople::IbmNotes::CalendarIntegration.any_instance
                                                       .stubs(:sync!)
                                                       .raises(::GobiertoCalendars::CalendarIntegration::Error)

        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit edit_admin_calendars_configuration_path(person.calendar)

            click_link "Sync now"

            assert has_content? "There has been a problem synchronizing the calendar"
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

            assert has_no_field?('google_calendar_invitation_url')

            assert has_no_checked_field?('Calendar 1')
            assert has_no_checked_field?('Calendar 2')
            assert has_no_checked_field?('Calendar 3')

            check 'Calendar 1'

            click_button 'Update'

            assert has_checked_field?('Calendar 1')
            assert has_no_checked_field?('Calendar 2')
            assert has_no_checked_field?('Calendar 3')

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

            assert has_text?("Username can't be blank")
            assert has_text?("Password can't be blank")
            assert has_text?("URL can't be blank")

            select "Microsoft Exchange", from: 'calendar_configuration_calendar_integration'

            click_button "Update"

            assert has_text?("Username can't be blank")
            assert has_text?("Password can't be blank")
            assert has_text?("URL can't be blank")
          end
        end
      end

      def test_regular_admin_manage_without_permissions
        setup_specific_permissions(regular_admin_without_permissions, module: "gobierto_people", site: site)
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

            assert has_no_content?('You do not have enough permissions to perform this action')
          end
        end
      end

    end
  end
end
