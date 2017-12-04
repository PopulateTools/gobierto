# frozen_string_literal: true

require "test_helper"
require "support/calendar_integration_helpers"

module GobiertoPeople
  module IbmNotes
    class CalendarIntegrationTest < ActiveSupport::TestCase
      include ::CalendarIntegrationHelpers

      def ibm_notes_configuration
        @ibm_notes_configuration ||= {
          ibm_notes_usr: 'ibm-notes-usr',
          ibm_notes_pwd: 'ibm-notes-pwd',
          ibm_notes_url: 'https://host.wadus.com/mail/foo.nsf/api/calendar/events'
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

      def setup
        super
        configure_ibm_notes_calendar_integration(
          collection: richard.calendar,
          data: ibm_notes_configuration
        )
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

      def test_sync_events_v9
        VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
          CalendarIntegration.sync_person_events(richard)
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

      def test_sync_events_updates_event_attributes
        VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
          CalendarIntegration.sync_person_events(richard)
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
          CalendarIntegration.sync_person_events(richard)
        end

        non_recurrent_event.reload
        recurrent_event_instance.reload

        assert_equal "Buscar alcaldessa al seu despatx i Sortida cap a l'acte Gran Via Corts Catalanes, 400", non_recurrent_event.title
        assert_equal rst_to_utc("2017-05-04 18:45:00"), non_recurrent_event.starts_at

        assert_equal "CAEM", recurrent_event_instance.title
        assert_equal "Sala de juntes 1a. planta Ajuntament", recurrent_event_instance.locations.first.name
        assert_equal 1, recurrent_event_instance.locations.size
      end

      def test_sync_events_removes_deleted_event_attributes
        VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
          CalendarIntegration.sync_person_events(richard)
        end

        # Add new data to events, and check it is removed after sync
        event = richard.events.find_by(external_id: "BD5EA243F9F715AAC1258116003ED56C-Lotus_Notes_Generated")
        GobiertoCalendars::EventLocation.create!(event: event, name: "I'll be deleted")

        assert 1, event.locations.size

        VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
          CalendarIntegration.sync_person_events(richard)
        end

        event.reload
        assert event.locations.empty?
      end

      # Se piden eventos en el intervalo [1,3], 1 y 3 son recurrentes y son el mismo, el 2 es uno no recurrente
      # De las 9 instancias del evento recurrente, la que tiene recurrenceId=20170407T113000Z (la segunda) da 404
      def test_sync_events_v8
        VCR.use_cassette("ibm_notes/person_events_collection_v8", decode_compressed_response: true, match_requests_on: [:host, :path]) do
          CalendarIntegration.sync_person_events(richard)
        end

        non_recurrent_events = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated$")
        recurrent_events_instances = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated/\\d{8}T\\d{6}Z$").order(:external_id)

        assert_equal 1, non_recurrent_events.count
        assert_equal 8, recurrent_events_instances.count

        assert_equal "rom", non_recurrent_events.first.title
        assert_equal "CD1B539AEB0D44D7C1258110003BB81E-Lotus_Notes_Generated", non_recurrent_events.first.external_id
        assert_equal rst_to_utc("2017-05-05 16:00:00"), non_recurrent_events.first.starts_at

        assert_equal "Coordinació Política Igualtat + dinar", recurrent_events_instances.first.title
        assert_equal "EE3C4CEA30187126C12580A300468AEF-Lotus_Notes_Generated/20170303T110000Z", recurrent_events_instances.first.external_id
        assert_equal rst_to_utc("2017-03-03 12:00:00"), recurrent_events_instances.first.starts_at

        assert_equal "Coordinació Política Igualtat + dinar", recurrent_events_instances.second.title
        assert_equal "EE3C4CEA30187126C12580A300468AEF-Lotus_Notes_Generated/20170505T100000Z", recurrent_events_instances.second.external_id
        assert_equal rst_to_utc("2017-05-05 12:00:00"), recurrent_events_instances.second.starts_at
      end

      # Only v8 will return past events instances, but use v9 cassette for simplicity
      def test_sync_events_marks_unreceived_upcoming_events_as_pending
        Timecop.freeze(Time.zone.parse("2017-05-03")) do
          VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            # Returns 3 events, all of them upcoming
            CalendarIntegration.sync_person_events(richard)
          end

          richard_synchronized_events = richard.events.synchronized

          assert_equal 3, richard_synchronized_events.count
          assert richard_synchronized_events.all?(&:active?)
        end

        Timecop.freeze(Time.zone.parse("2017-05-05 01:00:00")) do
          VCR.use_cassette("ibm_notes/person_events_collection_v9_mark_as_pending", decode_compressed_response: true, match_requests_on: [:host, :path]) do
            # Returns first event from the previous set, which is now past
            CalendarIntegration.sync_person_events(richard)
          end

          richard_synchronized_events = richard.events.synchronized.order(:external_id)

          assert_equal 3, richard_synchronized_events.count

          assert richard_synchronized_events.first.active?
          assert richard_synchronized_events.second.active?
          refute richard_synchronized_events.third.active?
        end
      end

      def test_sync_event_creates_new_event_with_location
        refute GobiertoCalendars::Event.exists?(external_id: new_ibm_notes_event.id)

        created_event_external_id = CalendarIntegration.sync_event(new_ibm_notes_event)

        assert GobiertoCalendars::Event.exists?(external_id: new_ibm_notes_event.id)
        assert_equal created_event_external_id, new_ibm_notes_event.id

        gobierto_event = GobiertoCalendars::Event.find_by(external_id: new_ibm_notes_event.id)

        assert_equal new_ibm_notes_event.title, gobierto_event.title
        assert_equal richard, gobierto_event.collection.container

        assert_equal "Ibm Notes new event location", gobierto_event.locations.first.name
      end

      def test_sync_event_updates_existing_event
        CalendarIntegration.sync_event(outdated_ibm_notes_event)

        updated_gobierto_event = GobiertoCalendars::Event.find_by(external_id: outdated_ibm_notes_event.id)

        assert updated_gobierto_event.published?
        assert_equal "Ibm Notes outdated event title - THIS HAS CHANGED", updated_gobierto_event.title
      end

      def test_sync_event_doesnt_create_duplicated_events
        CalendarIntegration.sync_event(outdated_ibm_notes_event)

        assert_no_difference "GobiertoCalendars::Event.count" do
          CalendarIntegration.sync_event(outdated_ibm_notes_event)
        end
      end

      def test_sync_event_creates_updates_and_removes_location_for_existing_gobierto_event
        outdated_ibm_notes_event_gobierto_event.save!
        ibm_notes_event_gobierto_event.save!

        ibm_notes_event = create_ibm_notes_event(location: nil)
        gobierto_event = GobiertoCalendars::Event.find_by!(external_id: ibm_notes_event.id)

        CalendarIntegration.sync_event(ibm_notes_event)

        gobierto_event.reload
        assert gobierto_event.locations.empty?

        ibm_notes_event.location = "Location name added afterwards"

        CalendarIntegration.sync_event(ibm_notes_event)
        gobierto_event.reload

        assert_equal "Location name added afterwards", gobierto_event.locations.first.name

        ibm_notes_event.location = "Location name updated afterwards"

        CalendarIntegration.sync_event(ibm_notes_event)
        gobierto_event.reload

        assert_equal "Location name updated afterwards", gobierto_event.locations.first.name

        ibm_notes_event.location = nil

        CalendarIntegration.sync_event(ibm_notes_event)
        gobierto_event.reload

        assert gobierto_event.locations.empty?
      end

      def test_sync_attendees
        # Cassette contains one confirmed attendee and two requested participants.
        VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true, match_requests_on: [:host, :path]) do
          CalendarIntegration.sync_person_events(richard)
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
          CalendarIntegration.sync_person_events(richard)
        end

        assert_equal 4, attendees.reload.size
      end

      def test_sync_invalid_recurring_event
        ibm_notes_event = create_ibm_notes_event_recurring_invalid_event(location: nil)

        CalendarIntegration.sync_event(ibm_notes_event, true)

        gobierto_event = GobiertoCalendars::Event.find_by(external_id: ibm_notes_event.id)
        assert gobierto_event.nil?

        CalendarIntegration.sync_event(ibm_notes_event, false)

        gobierto_event = GobiertoCalendars::Event.find_by(external_id: ibm_notes_event.id)
        assert gobierto_event.present?
      end
    end
  end
end
