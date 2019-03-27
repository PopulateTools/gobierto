# frozen_string_literal: true

require "test_helper"
require "support/calendar_integration_helpers"
require "support/event_helpers"

module GobiertoPeople
  module MicrosoftExchange
    class CalendarIntegrationTest < ActiveSupport::TestCase
      include ::CalendarIntegrationHelpers
      include ::EventHelpers

      def richard
        @richard ||= gobierto_people_people(:richard)
      end

      def tamara
        @tamara ||= gobierto_people_people(:tamara)
      end

      def site
        @site ||= sites(:madrid)
      end

      def filtering_rule
        @filtering_rule ||= gobierto_calendars_filtering_rules(:richard_calendar_configuration_filter)
      end

      def configure_microsoft_exchange_calendar_with_description
        @configure_microsoft_exchange_calendar_with_description ||= configure_microsoft_exchange_calendar_integration(collection: richard.calendar,
                                                                                                                      data: microsoft_exchange_configuration_with_description)
      end

      def microsoft_exchange_configuration_with_description
        @microsoft_exchange_configuration_with_description ||= {
          microsoft_exchange_url: "http://example.com/ews/exchange.asmx",
          microsoft_exchange_usr: "richard-me-username",
          microsoft_exchange_pwd: "richard-me-password",
          without_description: "0"
        }
      end

      def configure_microsoft_exchange_calendar_without_description
        @configure_microsoft_exchange_calendar_without_description ||= configure_microsoft_exchange_calendar_integration(collection: richard.calendar,
                                                                                                                         data: microsoft_exchange_configuration_without_description)
      end

      def microsoft_exchange_configuration_without_description
        @microsoft_exchange_configuration_without_description ||= {
          microsoft_exchange_url: "http://example.com/ews/exchange.asmx",
          microsoft_exchange_usr: "richard-me-username",
          microsoft_exchange_pwd: "richard-me-password",
          without_description: "1"
        }
      end

      def setup_mocks_for_synchronization(canned_responses)
        # mock event items
        mock_summarized_event_items = []
        mock_complete_event_items = []

        canned_responses.each do |canned_response|
          sumarized_event_item = mock
          sumarized_event_item.stubs(canned_response.except(:body))

          complete_event_item = mock
          event_body = mock
          event_body.stubs(text: canned_response[:body])
          complete_event_item.stubs(canned_response.merge(body: event_body))

          mock_summarized_event_items << sumarized_event_item
          mock_complete_event_items << complete_event_item
        end

        # mock target folder
        target_folder = mock
        target_folder.stubs(:expanded_items).returns(mock_summarized_event_items)
        target_folder.stubs(:display_name).returns(CalendarIntegration::TARGET_CALENDAR_NAME)

        # mock get events with description
        fake_collection = mock
        Exchanger::GetItem.stubs(:run).returns(fake_collection)
        fake_collection.stubs(:items).returns(mock_complete_event_items)

        # mock root folder
        root_folder = mock
        root_folder.stubs(:folders).returns([target_folder])

        Exchanger::Folder.stubs(:find).returns(root_folder)
      end

      def event_attributes
        {
          start: 1.hour.from_now,
          end: 2.hours.from_now,
          id: "external-id-1",
          subject: "Event 1",
          body: "Event 1 long description",
          sensitivity: "Normal",
          location: "Location 1"
        }
      end

      def calendar_service
        CalendarIntegration.new(richard)
      end

      def test_sync_returns_nil
        configure_microsoft_exchange_calendar_with_description

        target_folder = mock
        target_folder.stubs(:expanded_items).returns(nil)
        target_folder.stubs(:display_name).returns(CalendarIntegration::TARGET_CALENDAR_NAME)

        root_folder = mock
        root_folder.stubs(:folders).returns([target_folder])
        Exchanger::Folder.stubs(:find).returns(root_folder)

        assert_difference "GobiertoCalendars::Event.count", 0 do
          calendar_service.sync!
        end
      end

      def test_sync_events_with_description
        configure_microsoft_exchange_calendar_with_description

        event_1 = event_attributes
        event_2 = {
          id: "external-id-2",
          subject: "Event 2",
          body: nil,
          sensitivity: "Private",
          start: 1.hour.from_now,
          end: 2.hours.from_now,
          location: nil
        }

        setup_mocks_for_synchronization([event_1, event_2])

        assert_difference "GobiertoCalendars::Event.count", 1 do
          calendar_service.sync!
        end

        # event 1 checks

        event = richard.events.find_by(external_id: "external-id-1")
        assert_equal "Event 1", event.title
        assert_equal "Event 1 long description", event.description
        assert_equal 1, event.locations.size
        assert_equal "Location 1", event.first_location.name
      end

      def test_sync_events_without_description
        configure_microsoft_exchange_calendar_without_description

        event_1 = event_attributes
        event_2 = {
          id: "external-id-2",
          subject: "Event 2",
          body: nil,
          sensitivity: "Private",
          start: 1.hour.from_now,
          end: 2.hours.from_now,
          location: nil
        }

        setup_mocks_for_synchronization([event_1, event_2])

        assert_difference "GobiertoCalendars::Event.count", 1 do
          calendar_service.sync!
        end

        # event 1 checks

        event = richard.events.find_by(external_id: "external-id-1")
        assert_equal "Event 1", event.title
        assert_nil event.description
        assert_equal 1, event.locations.size
        assert_equal "Location 1", event.first_location.name
      end

      def test_sync_events_updates_event_attributes
        configure_microsoft_exchange_calendar_with_description

        setup_mocks_for_synchronization([event_attributes])
        calendar_service.sync!

        # simulate attributes are updated from OWA

        event_1 = event_attributes.merge(
          subject: "Updated event",
          body: "Updated description",
          location: "Updated location"
        )

        setup_mocks_for_synchronization([event_1])
        calendar_service.sync!

        # assert attributes get updated in Gobierto

        event = richard.events.find_by(external_id: "external-id-1")

        assert_equal "Updated event", event.title
        assert_equal "Updated description", event.description
        assert_equal "Updated location", event.first_location.name
        assert_equal 1, event.locations.size
      end

      def test_sync_events_after_being_unpublished
        configure_microsoft_exchange_calendar_with_description

        setup_mocks_for_synchronization([event_attributes])
        calendar_service.sync!

        event_1 = event_attributes.merge(
          subject: "Updated event",
          location: "Updated location",
          sensitivity: "Private"
        )

        setup_mocks_for_synchronization([event_1])
        assert_difference "GobiertoCalendars::Event.count", -1 do
          calendar_service.sync!
        end

        # assert attributes get updated in Gobierto

        assert_nil richard.events.find_by(external_id: "external-id-1")
      end

      def test_unreceived_events_are_drafted
        configure_microsoft_exchange_calendar_with_description

        other_person_event = create_event(person: tamara, external_id: "Tamara synced event")

        # sync two events

        event_1 = event_attributes
        event_2 = event_attributes.merge(id: "external-id-2")

        setup_mocks_for_synchronization([event_1, event_2])
        calendar_service.sync!

        event = richard.events.find_by(external_id: "external-id-1")

        assert event.published?

        # sync, only receiving the second event

        setup_mocks_for_synchronization([event_2])
        calendar_service.sync!

        # check first event is unpublished

        event.reload
        refute event.published?

        # check other people's events are not unpublished

        assert other_person_event.reload.published?
      end

      def test_sync_events_removes_deleted_locations
        configure_microsoft_exchange_calendar_with_description

        # syncrhonize event with location
        setup_mocks_for_synchronization([event_attributes])
        calendar_service.sync!

        event = richard.events.find_by(external_id: "external-id-1")
        assert_equal 1, event.locations.size

        # simulate location was removed from OWA

        event_1 = event_attributes.merge(location: "")

        setup_mocks_for_synchronization([event_1])
        calendar_service.sync!

        # assert location is deleted in Gobierto

        event.reload
        assert event.locations.empty?
      end

      def test_sync_with_errors
        configure_microsoft_exchange_calendar_with_description

        ::Exchanger::Folder.stubs(:find).raises(::Addressable::URI::InvalidURIError)

        assert_raises ::GobiertoCalendars::CalendarIntegration::AuthError do
          calendar_service.sync!
        end

        ::Exchanger::Folder.stubs(:find).raises(::HTTPClient::ConnectTimeoutError)

        assert_raises ::GobiertoCalendars::CalendarIntegration::TimeoutError do
          calendar_service.sync!
        end
      end

      def test_sync_when_root_folder_does_not_exist
        configure_microsoft_exchange_calendar_with_description

        ::Exchanger::Folder.stubs(:find).returns(nil)

        assert_raise ::GobiertoCalendars::CalendarIntegration::AuthError do
          calendar_service.sync!
        end
      end

      def test_sync_when_target_folder_does_not_exist
        configure_microsoft_exchange_calendar_with_description

        root_folder = mock
        root_folder.stubs(:folders).returns([])

        ::Exchanger::Folder.stubs(:find).returns(root_folder)

        assert_raise ::GobiertoCalendars::CalendarIntegration::Error do
          calendar_service.sync!
        end
      end

      def test_filter_events
        configure_microsoft_exchange_calendar_with_description

        # Create a rule with contains condition
        filtering_rule.condition = :not_contains
        filtering_rule.action = :ignore
        filtering_rule.value = "@"
        filtering_rule.remove_filtering_text = true
        filtering_rule.save!

        event_1 = event_attributes.merge(
          subject: "@ Event 1"
        )

        event_2 = {
          start: 1.hour.from_now,
          end: 2.hours.from_now,
          id: "external-id-2",
          subject: "Event 2",
          body: nil,
          sensitivity: "Normal",
          location: "Location 2"
        }

        setup_mocks_for_synchronization([event_1, event_2])

        assert_difference "GobiertoCalendars::Event.count", 1 do
          calendar_service.sync!
        end

        # event 1 checks
        event = richard.events.find_by(external_id: "external-id-1")
        assert_equal "Event 1", event.title
        assert_equal "Event 1 long description", event.description
        assert_equal 1, event.locations.size
        assert_equal "Location 1", event.first_location.name
      end
    end
  end
end
