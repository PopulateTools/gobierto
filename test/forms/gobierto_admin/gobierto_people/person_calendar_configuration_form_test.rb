# frozen_string_literal: true

require "test_helper"
require "support/calendar_integration_helpers"

module GobiertoAdmin
  module GobiertoPeople
    class PersonCalendarConfigurationFormTest < ActiveSupport::TestCase

      include ::CalendarIntegrationHelpers

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def site
        @site ||= sites(:madrid)
      end

      def ibm_notes_calendar_configuration_attributes
        @calendar_configuration_attributes ||= {
          person_id: person.id,
          ibm_notes_url: 'http://calendar-endpoint.com'
        }
      end

      def microsoft_exchange_calendar_configuration_attributes
        @microsoft_exchange_calendar_configuration_attributes ||= {
          person_id: person.id,
          microsoft_exchange_url: 'http://example.com/ews/exchange.asmx',
          microsoft_exchange_usr: 'me-username',
          microsoft_exchange_pwd: 'me-password'
        }
      end

      def calendar_conf
        person.calendar_configuration.data
      end

      def test_save_ibm_notes_calendar_configuration
        activate_ibm_notes_calendar_integration(site)

        calendar_configuration_form = PersonCalendarConfigurationForm.new(
          ibm_notes_calendar_configuration_attributes
        )

        assert calendar_configuration_form.save

        assert_equal 'http://calendar-endpoint.com', calendar_conf['endpoint']
      end

      def test_save_microsoft_exchange_calendar_configuration
        activate_microsoft_exchange_calendar_integration(site)

        calendar_configuration_form = PersonCalendarConfigurationForm.new(
          microsoft_exchange_calendar_configuration_attributes
        )

        assert calendar_configuration_form.save

        assert_equal 'http://example.com/ews/exchange.asmx', calendar_conf['microsoft_exchange_url']
        assert_equal 'me-username', calendar_conf['microsoft_exchange_usr']
        assert_equal 'me-password', ::SecretAttribute.decrypt(calendar_conf['microsoft_exchange_pwd'])
      end

      def test_html_dummy_credentials
        activate_microsoft_exchange_calendar_integration(site)

        # when password is set, a dummy placeholder is returned
        configure_microsoft_exchange_integration(person, { microsoft_exchange_pwd: 'wadus'})
        form = PersonCalendarConfigurationForm.new(person_id: person.id)

        assert_equal PersonCalendarConfigurationForm::ENCRYPTED_SETTING_PLACEHOLDER, form.dummy_microsoft_exchange_pwd

        # when password is not set, the original value is returned
        configure_microsoft_exchange_integration(person, {})
        form = PersonCalendarConfigurationForm.new(person_id: person.id)

        assert_nil form.dummy_microsoft_exchange_pwd

        # when password is blank, the original value is returned
        configure_microsoft_exchange_integration(person, { microsoft_exchange_pwd: ''})
        form = PersonCalendarConfigurationForm.new(person_id: person.id)

        assert_equal '', form.dummy_microsoft_exchange_pwd
      end

    end
  end
end
