# frozen_string_literal: true

require "test_helper"
require "support/calendar_integration_helpers"

module GobiertoPeople
  class RemoteCalendarsTest < ActiveSupport::TestCase

    include ::CalendarIntegrationHelpers

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def ibm_notes_configuration
      @ibm_notes_configuration ||= {
        ibm_notes_usr: "ibm-notes-usr",
        ibm_notes_pwd: "ibm-notes-pwd",
        ibm_notes_url: "http://ibm-calendar/richard",
        without_description: "0"
      }
    end

    def microsoft_exchange_configuration
      @microsoft_exchange_configuration ||= {
        microsoft_exchange_usr: "microsoft-exchange-usr",
        microsoft_exchange_pwd: "microsoft-exchange-pwd",
        microsoft_exchange_url: "http://me-calendar/richard",
        without_description: "0"
      }
    end

    def test_sync_with_invalid_configuration_credentials_does_not_propagate_ui_errors
      clear_calendar_configurations

      configure_ibm_notes_calendar_integration(
        collection: person.calendar,
        data: ibm_notes_configuration
      )

      ::IbmNotes::Api.stubs(:get_person_events).raises(::IbmNotes::InvalidCredentials)

      assert_nothing_raised do
        GobiertoPeople::RemoteCalendars.sync
      end

      configure_microsoft_exchange_calendar_integration(
        collection: person.calendar,
        data: microsoft_exchange_configuration
      )

      ::Exchanger::Folder.stubs(:find).returns(nil)

      assert_nothing_raised do
        GobiertoPeople::RemoteCalendars.sync
      end
    end

  end
end
