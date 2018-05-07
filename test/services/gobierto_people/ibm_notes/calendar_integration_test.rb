# frozen_string_literal: true

require "test_helper"
require "support/calendar_integration_helpers"

module GobiertoPeople
  module IbmNotes
    class CalendarIntegrationTest < ActiveSupport::TestCase
      include ::CalendarIntegrationHelpers

      def freeze_date
        Time.zone.parse("2017-03-01 01:00:00")
      end

      def filtering_rule
        @filtering_rule ||= gobierto_calendars_filtering_rules(:richard_calendar_configuration_filter)
      end

      def configure_ibm_notes_calendar_with_description
        @configure_ibm_notes_calendar_with_description ||= configure_ibm_notes_calendar_integration(collection: richard.calendar,
                                                                                                    data: ibm_notes_configuration_with_description)
      end

      def ibm_notes_configuration_with_description
        @ibm_notes_configuration ||= {
          ibm_notes_usr: 'ibm-notes-usr',
          ibm_notes_pwd: 'ibm-notes-pwd',
          ibm_notes_url: 'https://host.wadus.com/mail/foo.nsf/api/calendar/events',
          without_description: '0'
        }
      end

      def configure_ibm_notes_calendar_without_description
        @configure_ibm_notes_calendar_without_description ||= configure_ibm_notes_calendar_integration(collection: richard.calendar,
                                                                                                       data: ibm_notes_configuration_without_description)
      end

      def ibm_notes_configuration_without_description
        @ibm_notes_configuration ||= {
          ibm_notes_usr: 'ibm-notes-usr',
          ibm_notes_pwd: 'ibm-notes-pwd',
          ibm_notes_url: 'https://host.wadus.com/mail/foo.nsf/api/calendar/events',
          without_description: '1'
        }
      end

      def richard
        @richard ||= gobierto_people_people(:richard)
      end

      def nelson
        @nelson ||= gobierto_people_people(:nelson)
      end

      def site
        @site ||= sites(:madrid)
      end

      def utc_time(date)
        d = Time.parse(date)
        Time.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
      end

      def rst_to_utc(date)
        ActiveSupport::TimeZone["Madrid"].parse(date).utc
      end

      def create_ibm_notes_event(params = {})
        ::IbmNotes::PersonEvent.new(richard, "id" => params[:id] || "Ibm Notes event ID",
                                             "summary"  => params[:summary] || "Ibm Notes event summary",
                                             "location" => params.has_key?(:location) ? params[:location] : "Ibm Notes event location",
                                             "start"    => { "date" => "2017-04-11", "time" => "10:00:00", "utc" => true },
                                             "end"      => { "date" => "2017-04-11", "time" => "11:00:00", "utc" => true })
      end

      def create_ibm_notes_event_recurring_invalid_event(params = {})
        ::IbmNotes::PersonEvent.new(richard, "id" => params[:id] || "Ibm Notes event ID",
                                             "summary"  => params[:summary] || "Ibm Notes event summary",
                                             "location" => params.has_key?(:location) ? params[:location] : "Ibm Notes event location",
                                             "start"    => { "date" => "2037-04-11", "time" => "10:00:00", "utc" => true },
                                             "end"      => { "date" => "2037-04-11", "time" => "11:00:00", "utc" => true })
      end

      def new_ibm_notes_event
        @new_ibm_notes_event ||= create_ibm_notes_event(
          id: "Ibm Notes new event ID",
          summary: "Ibm Notes new event summary",
          location: "Ibm Notes new event location"
        )
      end

      def outdated_ibm_notes_event
        @outdated_ibm_notes_event ||= create_ibm_notes_event(
          id: "Ibm Notes outdated event ID",
          summary: "Ibm Notes outdated event title - THIS HAS CHANGED",
          location: "Ibm Notes outdated event location - THIS HAS CHANGED"
        )
      end

      def ibm_notes_curring_future_event
        @ibm_notes_event_gobierto_event ||= GobiertoCalendars::Event.new(
          site: site,
          external_id: "Ibm Notes event future ID",
          title: "Ibm Notes event future title",
          starts_at: utc_time("2037-04-11 10:00:00"),
          ends_at:   utc_time("2037-04-11 11:00:00"),
          state: GobiertoCalendars::Event.states["published"],
          collection: richard.events_collection
        )
      end

      def ibm_notes_event_gobierto_event
        @ibm_notes_event_gobierto_event ||= GobiertoCalendars::Event.new(
          site: site,
          external_id: "Ibm Notes event ID",
          title: "Ibm Notes event title",
          starts_at: utc_time("2017-04-11 10:00:00"),
          ends_at:   utc_time("2017-04-11 11:00:00"),
          state: GobiertoCalendars::Event.states["published"],
          collection: richard.events_collection
        )
      end

      def outdated_ibm_notes_event_gobierto_event
        @outdated_ibm_notes_event_gobierto_event ||= GobiertoCalendars::Event.new(
          site: site,
          external_id: "Ibm Notes outdated event ID",
          title: "Ibm Notes outdated event title",
          starts_at: utc_time("2017-04-11 10:00:00"),
          ends_at:   utc_time("2017-04-11 11:00:00"),
          state: GobiertoCalendars::Event.states["published"],
          collection: richard.events_collection
        )
      end

      def calendar_service
        CalendarIntegration.new(richard)
      end

      def test_sync_events_v9_with_description
        configure_ibm_notes_calendar_with_description

        Timecop.freeze(freeze_date) do
          VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            calendar_service.sync!
          end

          non_recurrent_events = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated$")
          recurrent_events_instances = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated/\\d{8}T\\d{6}Z$")

          assert_equal 2, non_recurrent_events.count
          assert_equal 1, recurrent_events_instances.count

          assert_equal "Buscar alcaldessa al seu despatx i Sortida cap a l'acte Gran Via Corts Catalanes, 400", non_recurrent_events.first.title
          assert_equal rst_to_utc("2017-05-04 18:45:00"), non_recurrent_events.first.starts_at.utc

          assert_equal "Lliurament Premis Rac", non_recurrent_events.second.title
          assert_equal rst_to_utc("2017-05-04 19:30:00"), non_recurrent_events.second.starts_at.utc

          assert_equal "CAEM", recurrent_events_instances.first.title
          assert_equal rst_to_utc("2017-05-05 09:00:00"), recurrent_events_instances.first.starts_at
        end
      end

      def test_sync_events_v9_without_description
        configure_ibm_notes_calendar_without_description

        Timecop.freeze(freeze_date) do
          VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            calendar_service.sync!
          end

          non_recurrent_events = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated$")
          recurrent_events_instances = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated/\\d{8}T\\d{6}Z$")

          assert_equal 2, non_recurrent_events.count
          assert_equal 1, recurrent_events_instances.count

          assert_equal "Buscar alcaldessa al seu despatx i Sortida cap a l'acte Gran Via Corts Catalanes, 400", non_recurrent_events.first.title
          assert_equal rst_to_utc("2017-05-04 18:45:00"), non_recurrent_events.first.starts_at.utc
          assert_nil non_recurrent_events.first.description

          assert_equal "Lliurament Premis Rac", non_recurrent_events.second.title
          assert_equal rst_to_utc("2017-05-04 19:30:00"), non_recurrent_events.second.starts_at.utc
          assert_nil non_recurrent_events.second.description

          assert_equal "CAEM", recurrent_events_instances.first.title
          assert_equal rst_to_utc("2017-05-05 09:00:00"), recurrent_events_instances.first.starts_at
          assert_nil recurrent_events_instances.first.description
        end
      end

      def test_sync_events_updates_event_attributes
        configure_ibm_notes_calendar_with_description

        Timecop.freeze(freeze_date) do
          VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            calendar_service.sync!
          end

          # Change arbitrary data, and check it gets  updated accordingly after the
          # next synchronization

          non_recurrent_event = richard.events.find_by(external_id: "BD5EA243F9F715AAC1258116003ED56C-Lotus_Notes_Generated")
          non_recurrent_event.title = "Old non recurrent event title"
          non_recurrent_event.starts_at = utc_time("2017-05-05 10:00:00")
          non_recurrent_event.save!

          recurrent_event_instance = richard.events.find_by(external_id: "D2E5B40E6AAEAED4C125808E0035A6A0-Lotus_Notes_Generated/20170503T073000Z")
          recurrent_event_instance.title = "Old recurrent event instance title"
          recurrent_event_instance.locations.first.update_attributes!(name: "Old location")
          recurrent_event_instance.save!

          VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            calendar_service.sync!
          end

          non_recurrent_event.reload
          recurrent_event_instance.reload

          assert_equal "Buscar alcaldessa al seu despatx i Sortida cap a l'acte Gran Via Corts Catalanes, 400", non_recurrent_event.title
          assert_equal rst_to_utc("2017-05-04 18:45:00"), non_recurrent_event.starts_at

          assert_equal "CAEM", recurrent_event_instance.title
          assert_equal "Sala de juntes 1a. planta Ajuntament", recurrent_event_instance.locations.first.name
          assert_equal 1, recurrent_event_instance.locations.size
        end
      end

      def test_sync_events_removes_deleted_event_attributes
        configure_ibm_notes_calendar_with_description

        Timecop.freeze(freeze_date) do
          VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            calendar_service.sync!
          end

          # Add new data to events, and check it is removed after sync
          event = richard.events.find_by(external_id: "BD5EA243F9F715AAC1258116003ED56C-Lotus_Notes_Generated")
          GobiertoCalendars::EventLocation.create!(event: event, name: "I'll be deleted")

          assert 1, event.locations.size

          VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            calendar_service.sync!
          end

          event.reload
          assert event.locations.empty?
        end
      end

      # Se piden eventos en el intervalo [1,3], 1 y 3 son recurrentes y son el mismo, el 2 es uno no recurrente
      # De las 9 instancias del evento recurrente, la que tiene recurrenceId=20170407T113000Z (la segunda) da 404
      def test_sync_events_v8
        configure_ibm_notes_calendar_with_description

        Timecop.freeze(freeze_date) do
          VCR.use_cassette("ibm_notes/person_events_collection_v8", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            calendar_service.sync!
          end

          non_recurrent_events = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated$")
          recurrent_events_instances = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated/\\d{8}T\\d{6}Z$").order(:external_id)

          assert_equal 1, non_recurrent_events.count
          assert_equal 8, recurrent_events_instances.count

          assert_equal "@ rom evento", non_recurrent_events.first.title
          assert_equal "CD1B539AEB0D44D7C1258110003BB81E-Lotus_Notes_Generated", non_recurrent_events.first.external_id
          assert_equal rst_to_utc("2017-05-05 16:00:00"), non_recurrent_events.first.starts_at

          assert_equal "@ Coordinació Política Igualtat + dinar", recurrent_events_instances.first.title
          assert_equal "EE3C4CEA30187126C12580A300468AEF-Lotus_Notes_Generated/20170303T110000Z", recurrent_events_instances.first.external_id
          assert_equal rst_to_utc("2017-03-03 12:00:00"), recurrent_events_instances.first.starts_at

          assert_equal "@ Coordinació Política Igualtat + dinar", recurrent_events_instances.second.title
          assert_equal "EE3C4CEA30187126C12580A300468AEF-Lotus_Notes_Generated/20170505T100000Z", recurrent_events_instances.second.external_id
          assert_equal rst_to_utc("2017-05-05 12:00:00"), recurrent_events_instances.second.starts_at
        end
      end

      # Only v8 will return past events instances, but use v9 cassette for simplicity
      def test_sync_events_marks_unreceived_upcoming_events_as_pending
        configure_ibm_notes_calendar_with_description

        Timecop.freeze(Time.zone.parse("2017-05-03")) do
          VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            # Returns 3 events, all of them upcoming
            calendar_service.sync!
          end

          richard_synchronized_events = richard.events.synchronized

          assert_equal 3, richard_synchronized_events.count
          assert richard_synchronized_events.all?(&:active?)
        end

        Timecop.freeze(Time.zone.parse("2017-05-05 01:00:00")) do
          VCR.use_cassette("ibm_notes/person_events_collection_v9_mark_as_pending", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            # Returns first event from the previous set, which is now past
            calendar_service.sync!
          end

          richard_synchronized_events = richard.events.synchronized.order(:external_id)

          assert_equal 3, richard_synchronized_events.count

          assert richard_synchronized_events.first.active?
          assert richard_synchronized_events.second.active?
          refute richard_synchronized_events.third.active?
        end
      end

      def test_sync_event_creates_new_event_with_location
        configure_ibm_notes_calendar_with_description

        Timecop.freeze(freeze_date) do
          refute GobiertoCalendars::Event.exists?(external_id: new_ibm_notes_event.id)

          created_event_external_id = calendar_service.sync_event(new_ibm_notes_event)

          assert GobiertoCalendars::Event.exists?(external_id: new_ibm_notes_event.id)
          assert_equal created_event_external_id, new_ibm_notes_event.id

          gobierto_event = GobiertoCalendars::Event.find_by(external_id: new_ibm_notes_event.id)

          assert_equal new_ibm_notes_event.title, gobierto_event.title
          assert_equal richard, gobierto_event.collection.container

          assert_equal "Ibm Notes new event location", gobierto_event.locations.first.name
        end
      end

      def test_sync_event_updates_existing_event
        configure_ibm_notes_calendar_with_description

        Timecop.freeze(freeze_date) do
          calendar_service.sync_event(outdated_ibm_notes_event)

          updated_gobierto_event = GobiertoCalendars::Event.find_by(external_id: outdated_ibm_notes_event.id)

          assert updated_gobierto_event.published?
          assert_equal "Ibm Notes outdated event title - THIS HAS CHANGED", updated_gobierto_event.title
        end
      end

      def test_sync_event_doesnt_create_duplicated_events
        configure_ibm_notes_calendar_with_description

        Timecop.freeze(freeze_date) do
          calendar_service.sync_event(outdated_ibm_notes_event)

          assert_no_difference "GobiertoCalendars::Event.count" do
            calendar_service.sync_event(outdated_ibm_notes_event)
          end
        end
      end

      def test_sync_event_creates_updates_and_removes_location_for_existing_gobierto_event
        configure_ibm_notes_calendar_with_description

        Timecop.freeze(freeze_date) do
          outdated_ibm_notes_event_gobierto_event.save!
          ibm_notes_event_gobierto_event.save!

          ibm_notes_event = create_ibm_notes_event(location: nil)
          gobierto_event = GobiertoCalendars::Event.find_by!(external_id: ibm_notes_event.id)

          calendar_service.sync_event(ibm_notes_event)

          gobierto_event.reload
          assert gobierto_event.locations.empty?

          ibm_notes_event.location = "Location name added afterwards"

          calendar_service.sync_event(ibm_notes_event)
          gobierto_event.reload

          assert_equal "Location name added afterwards", gobierto_event.locations.first.name

          ibm_notes_event.location = "Location name updated afterwards"

          calendar_service.sync_event(ibm_notes_event)
          gobierto_event.reload

          assert_equal "Location name updated afterwards", gobierto_event.locations.first.name

          ibm_notes_event.location = nil

          calendar_service.sync_event(ibm_notes_event)
          gobierto_event.reload

          assert gobierto_event.locations.empty?
        end
      end

      def test_sync_attendees
        configure_ibm_notes_calendar_with_description

        Timecop.freeze(freeze_date) do
          # Cassette contains one confirmed attendee and two requested participants.
          VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            calendar_service.sync!
          end

          event = richard.events.find_by(external_id: "D2E5B40E6AAEAED4C125808E0035A6A0-Lotus_Notes_Generated/20170503T073000Z")
          attendees = event.attendees

          assert_equal 4, attendees.size

          assert_equal "Josep M. Farreras", attendees.first.name
          assert_equal "Horatio Nelson", attendees.second.person.name
          assert_equal nelson, attendees.second.person
          assert_equal richard, attendees.fourth.person

          # Check if Nelson accepts afterwards, Josep is not duplicated on second sync

          event.attendees.second.delete

          VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            calendar_service.sync!
          end

          assert_equal 4, attendees.reload.size
        end
      end

      def test_sync_event_outside_range
        configure_ibm_notes_calendar_with_description

        ibm_notes_event = create_ibm_notes_event_recurring_invalid_event(location: nil)

        Timecop.freeze(freeze_date) do
          calendar_service.sync_event(ibm_notes_event)

          gobierto_event = GobiertoCalendars::Event.find_by(external_id: ibm_notes_event.id)
          assert gobierto_event.nil?
        end
      end

      def test_sync_with_errors
        configure_ibm_notes_calendar_with_description

        ::IbmNotes::Api.stubs(:get_person_events).raises(::IbmNotes::InvalidCredentials)

        assert_raises ::GobiertoCalendars::CalendarIntegration::AuthError do
          calendar_service.sync!
        end

        ::IbmNotes::Api.stubs(:get_person_events).raises(::IbmNotes::ServiceUnavailable)

        assert_raises ::GobiertoCalendars::CalendarIntegration::TimeoutError do
          calendar_service.sync!
        end

        ::IbmNotes::Api.stubs(:get_person_events).raises(::JSON::ParserError)

        assert_raises ::GobiertoCalendars::CalendarIntegration::Error do
          calendar_service.sync!
        end
      end

      def test_filter_events
        configure_ibm_notes_calendar_with_description

        # Create a rule with contains condition
        filtering_rule.condition = :not_contains
        filtering_rule.value = "@"
        filtering_rule.action = :ignore
        filtering_rule.remove_filtering_text = true
        filtering_rule.save!

        Timecop.freeze(freeze_date) do
          VCR.use_cassette("ibm_notes/person_events_collection_v8", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            calendar_service.sync!
          end

          non_recurrent_events = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated$")
          recurrent_events_instances = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated/\\d{8}T\\d{6}Z$").order(:external_id)

          assert_equal 1, non_recurrent_events.count
          assert_equal 8, recurrent_events_instances.count

          assert_equal "rom evento", non_recurrent_events.first.title
          assert_equal "CD1B539AEB0D44D7C1258110003BB81E-Lotus_Notes_Generated", non_recurrent_events.first.external_id
          assert_equal rst_to_utc("2017-05-05 16:00:00"), non_recurrent_events.first.starts_at
        end
      end

      def test_event_instances_urls
        api_host = "https://example.com"
        recurrent_event_href = "/mail/foobar.nsf/api/calendar/events/E2128A9CA256D103C125801D004F0A76_1-Lotus_ReadRange_Generated"
        recurrent_event_url = "#{api_host}#{recurrent_event_href}"

        past_instance_recurrence_id  = "#{1.year.ago.strftime("%Y%m%d")}T183000Z"
        close_instance_recurrence_id = "#{1.day.from_now.strftime("%Y%m%d")}T183000Z"
        far_instance_recurrence_id   = "#{1.year.from_now.strftime("%Y%m%d")}T183000Z"

        response_data = {
          "instances" => [
            {
              "recurrenceId" => past_instance_recurrence_id,
              "href" => "#{recurrent_event_href}/#{past_instance_recurrence_id}"
            },
            {
              "recurrenceId" => close_instance_recurrence_id,
              "href" => "#{recurrent_event_href}/#{close_instance_recurrence_id}"
            },
            {
              "recurrenceId" => far_instance_recurrence_id,
              "href" => "#{recurrent_event_href}/#{far_instance_recurrence_id}"
            }
          ]
        }

        calendar_integration = ::GobiertoPeople::IbmNotes::CalendarIntegration.new(richard)

        ::IbmNotes::Api.stubs(:get_recurrent_event_instances).returns(response_data)

        filtered_urls = calendar_integration.send(:event_instances_urls, recurrent_event_url)

        # ensure event instances out of sync range are filtered
        assert_equal 1, filtered_urls.size
        assert filtered_urls.first.include?(close_instance_recurrence_id)
      end

    end
  end
end
