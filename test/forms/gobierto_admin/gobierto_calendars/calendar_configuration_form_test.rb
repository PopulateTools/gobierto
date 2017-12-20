# frozen_string_literal: true

require "test_helper"
require "support/calendar_integration_helpers"

module GobiertoAdmin
  module GobiertoCalendars
    class CalendarConfigurationFormTest < ActiveSupport::TestCase
      include ::CalendarIntegrationHelpers

      def collection
        @collection ||= gobierto_common_collections(:richard_calendar)
      end

      def site
        @site ||= sites(:madrid)
      end

      def ibm_notes_calendar_configuration_attributes
        @calendar_configuration_attributes ||= {
          current_site: site,
          collection: collection,
          calendar_integration: 'ibm_notes',
          ibm_notes_usr: 'ibm-username',
          ibm_notes_pwd: 'ibm-password',
          ibm_notes_url: 'http://calendar-endpoint.com'
        }
      end

      def microsfot_exchange_configuration
        @microsoft_exchange_configuration ||= {
          microsoft_exchange_usr: 'me-username',
          microsoft_exchange_pwd: 'me-password',
          microsoft_exchange_url: 'http://example.com/ews/exchange.asmx'
        }
      end

      def microsoft_exchange_calendar_configuration_attributes
        @microsoft_exchange_credentials ||= {
          current_site: site,
          collection: collection,
          calendar_integration: 'microsoft_exchange'
        }.merge(microsfot_exchange_configuration)
      end

      def calendar_conf
        collection.calendar_configuration.data
      end

      def test_save_ibm_notes_calendar_configuration
        calendar_configuration_form = CalendarConfigurationForm.new(
          ibm_notes_calendar_configuration_attributes
        )

        assert calendar_configuration_form.save

        assert_equal 'ibm_notes', collection.calendar_configuration.integration_name
        assert_equal 'ibm-username', calendar_conf['ibm_notes_usr']
        assert_equal 'ibm-password', ::SecretAttribute.decrypt(calendar_conf['ibm_notes_pwd'])
        assert_equal 'http://calendar-endpoint.com', calendar_conf['ibm_notes_url']
      end

      def test_save_microsoft_exchange_calendar_configuration
        calendar_configuration_form = CalendarConfigurationForm.new(
          microsoft_exchange_calendar_configuration_attributes
        )

        assert calendar_configuration_form.save

        assert_equal 'microsoft_exchange', collection.calendar_configuration.integration_name
        assert_equal 'http://example.com/ews/exchange.asmx', calendar_conf['microsoft_exchange_url']
        assert_equal 'me-username', calendar_conf['microsoft_exchange_usr']
        assert_equal 'me-password', ::SecretAttribute.decrypt(calendar_conf['microsoft_exchange_pwd'])
      end

      def test_save_incomplete_calendar_configuration
        calendar_configuration_form = CalendarConfigurationForm.new(
          microsoft_exchange_calendar_configuration_attributes.except(:microsoft_exchange_url)
        )

        refute calendar_configuration_form.valid?

        error_keys = calendar_configuration_form.errors.messages.keys

        assert error_keys.include?(:microsoft_exchange_url)
      end

      def test_change_calendar_integration_removes_previous_settings
        configure_microsoft_exchange_calendar_integration(collection: collection, data: microsfot_exchange_configuration)

        calendar_configuration = collection.calendar_configuration

        microsoft_exchange_keys = ['microsoft_exchange_usr', 'microsoft_exchange_pwd', 'microsoft_exchange_url']
        ibm_notes_keys = ['ibm_notes_usr', 'ibm_notes_pwd', 'ibm_notes_url']

        assert array_match(microsoft_exchange_keys, calendar_configuration.data.keys)

        calendar_configuration_form = CalendarConfigurationForm.new(
          ibm_notes_calendar_configuration_attributes
        )

        assert calendar_configuration_form.save
        assert array_match(ibm_notes_keys, calendar_configuration.reload.data.keys)
      end

      def test_html_dummy_credentials
        # when password is set, a dummy placeholder is returned

        configure_microsoft_exchange_calendar_integration(
          collection: collection,
          data: microsfot_exchange_configuration
        )

        form = CalendarConfigurationForm.new(collection: collection)

        assert_equal CalendarConfigurationForm::ENCRYPTED_SETTING_PLACEHOLDER, form.dummy_microsoft_exchange_pwd

        # when password is not set, the original value is returned

        clear_calendar_configurations

        form = CalendarConfigurationForm.new(collection: collection)

        assert_nil form.dummy_microsoft_exchange_pwd

        # when password is blank, the original value is returned

        configure_microsoft_exchange_calendar_integration(
          collection: collection,
          data: { microsoft_exchange_pwd: '' }
        )

        form = CalendarConfigurationForm.new(collection: collection)

        assert_nil form.dummy_microsoft_exchange_pwd
      end

    end
  end
end
