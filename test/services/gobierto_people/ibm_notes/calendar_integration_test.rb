require 'test_helper'
require 'support/calendar_integration_helpers'

module GobiertoPeople
  module IbmNotes
    class CalendarIntegrationTest < ActiveSupport::TestCase

      include ::CalendarIntegrationHelpers

      def richard
        @richard ||= gobierto_people_people(:richard)
      end

      def tamara
        @tamara ||= gobierto_people_people(:tamara)
      end

      def setup
        super
        outdated_ibm_notes_event_gobierto_event.save!
      end

      def utc_time(date)
        d = Time.parse(date)
        Time.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
      end

      def create_ibm_notes_event(params = {})
        ::IbmNotes::PersonEvent.new((params[:person] || richard), {
          'id'       => params[:id] || 'Ibm Notes event ID',
          'summary'  => params[:summary] || 'Ibm Notes event summary',
          'location' => params.has_key?(:location) ? params[:location] : 'Ibm Notes event location',
          'start'    => { 'date' => '2017-04-11', 'time' => '10:00:00', 'utc' => true },
          'end'      => { 'date' => '2017-04-11', 'time' => '11:00:00', 'utc' => true }
        })
      end

      def new_ibm_notes_event
        @new_ibm_notes_event ||= create_ibm_notes_event(
          id: 'Ibm Notes new event ID',
          summary: 'Ibm Notes new event summary',
          location: 'Ibm Notes new event location',
        )
      end

      def outdated_ibm_notes_event
        @outdated_ibm_notes_event ||= create_ibm_notes_event(
          id: 'Ibm Notes outdated event ID',
          summary: 'Ibm Notes outdated event title - THIS HAS CHANGED',
          location: 'Ibm Notes outdated event location - THIS HAS CHANGED'
        )
      end

      def outdated_ibm_notes_event_gobierto_event
        @outdated_ibm_notes_event_gobierto_event ||= GobiertoPeople::PersonEvent.new(
          external_id: 'Ibm Notes outdated event ID',
          title: 'Ibm Notes outdated event title',
          starts_at: utc_time("2017-04-11 10:00:00"),
          ends_at:   utc_time("2017-04-11 11:00:00"),
          state: GobiertoPeople::PersonEvent.states['published'],
          person: richard
        )
      end

      def test_sync_events_v9
        activate_calendar_integration(sites(:madrid))

        calendar_conf = richard.calendar_configuration
        calendar_conf.data = {endpoint: 'https://host.wadus.com/mail/foo.nsf/api/calendar/events' }
        calendar_conf.save!

        VCR.use_cassette('ibm_notes/person_events_collection_v9', decode_compressed_response: true) do

          CalendarIntegration.sync_person_events(richard)

          non_recurrent_events       = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated$")
          recurrent_events_instances = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated/\\d{8}T\\d{6}Z$")

          assert_equal 2, non_recurrent_events.count
          assert_equal 1, recurrent_events_instances.count

          assert_equal "Buscar alcaldessa al seu despatx i Sortida cap a l'acte Gran Via Corts Catalanes, 400", non_recurrent_events.first.title
          assert_equal ActiveSupport::TimeZone['Madrid'].parse("2017-05-04 18:45:00").utc, non_recurrent_events.first.starts_at

          assert_equal "Lliurament Premis Rac", non_recurrent_events.second.title
          assert_equal ActiveSupport::TimeZone['Madrid'].parse("2017-05-04 19:30:00").utc, non_recurrent_events.second.starts_at

          assert_equal "CAEM", recurrent_events_instances.first.title
          assert_equal ActiveSupport::TimeZone['Madrid'].parse("2017-05-05 09:00:00").utc, recurrent_events_instances.first.starts_at
        end
      end

      # Se piden eventos en el intervalo [1,3], 1 y 3 son recurrentes y son el mismo, el 2 es uno no recurrente
      # De las 9 instancias del evento recurrente, la que tiene recurrenceId=20170407T113000Z (la segunda) da 404
      def test_sync_events_v8
        activate_calendar_integration(sites(:madrid))

        calendar_conf = tamara.calendar_configuration
        calendar_conf.data = {endpoint: 'https://host.wadus.com/mail/bar.nsf/api/calendar/events' }
        calendar_conf.save!

        VCR.use_cassette('ibm_notes/person_events_collection_v8', decode_compressed_response: true) do

          CalendarIntegration.sync_person_events(tamara)

          non_recurrent_events       = tamara.events.where("external_id ~* ?", "-Lotus_Notes_Generated$")
          recurrent_events_instances = tamara.events.where("external_id ~* ?", "-Lotus_Notes_Generated/\\d{8}T\\d{6}Z$").order(:external_id)

          assert_equal 1, non_recurrent_events.count
          assert_equal 8, recurrent_events_instances.count

          assert_equal "rom", non_recurrent_events.first.title
          assert_equal 'CD1B539AEB0D44D7C1258110003BB81E-Lotus_Notes_Generated', non_recurrent_events.first.external_id
          assert_equal ActiveSupport::TimeZone['Madrid'].parse('2017-05-05 16:00:00').utc, non_recurrent_events.first.starts_at

          assert_equal "Coordinació Política Igualtat + dinar", recurrent_events_instances.first.title
          assert_equal 'EE3C4CEA30187126C12580A300468AEF-Lotus_Notes_Generated/20170303T110000Z', recurrent_events_instances.first.external_id
          assert_equal ActiveSupport::TimeZone['Madrid'].parse('2017-03-03 12:00:00').utc, recurrent_events_instances.first.starts_at

          assert_equal "Coordinació Política Igualtat + dinar", recurrent_events_instances.second.title
          assert_equal 'EE3C4CEA30187126C12580A300468AEF-Lotus_Notes_Generated/20170505T100000Z', recurrent_events_instances.second.external_id
          assert_equal ActiveSupport::TimeZone['Madrid'].parse('2017-05-05 12:00:00').utc, recurrent_events_instances.second.starts_at
        end
      end

      def test_sync_events_v9_mark_unreceived_events_as_pending
        activate_calendar_integration(sites(:madrid))

        calendar_conf = richard.calendar_configuration
        calendar_conf.data = {endpoint: 'https://host.wadus.com/mail/foo.nsf/api/calendar/events' }
        calendar_conf.save!

        VCR.use_cassette('ibm_notes/person_events_collection_v9', decode_compressed_response: true) do
          CalendarIntegration.sync_person_events(richard)
        end

        non_recurrent_events = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated$")

        assert_equal 2, non_recurrent_events.count

        assert non_recurrent_events.first.active?
        assert non_recurrent_events.second.active?

        VCR.use_cassette('ibm_notes/person_events_collection_v9_mark_as_pending', decode_compressed_response: true) do
          CalendarIntegration.sync_person_events(richard)
        end

        non_recurrent_events = richard.events.where("external_id ~* ?", "-Lotus_Notes_Generated$").order(:external_id)

        assert_equal 2, non_recurrent_events.count

        refute non_recurrent_events.first.active?
        assert non_recurrent_events.second.active?
      end

      def test_sync_creates_new_event_with_location
        refute new_ibm_notes_event.has_gobierto_event?

        CalendarIntegration.sync_event(new_ibm_notes_event)

        refute new_ibm_notes_event.gobierto_event_outdated?
        assert new_ibm_notes_event.has_gobierto_event?

        gobierto_event = new_ibm_notes_event.gobierto_event

        assert_equal new_ibm_notes_event.title, gobierto_event.title
        assert_equal richard, gobierto_event.person

        assert_equal 'Ibm Notes new event location', gobierto_event.locations.first.name
      end

      def test_sync_updates_existing_event
        assert outdated_ibm_notes_event.gobierto_event_outdated?

        CalendarIntegration.sync_event(outdated_ibm_notes_event)

        updated_gobierto_event = outdated_ibm_notes_event.gobierto_event

        refute outdated_ibm_notes_event.gobierto_event_outdated?
        assert updated_gobierto_event.published?
        assert_equal 'Ibm Notes outdated event title - THIS HAS CHANGED', updated_gobierto_event.title
      end

      def test_sync_doesnt_create_duplicated_events
        assert outdated_ibm_notes_event.gobierto_event_outdated?

        CalendarIntegration.sync_event(outdated_ibm_notes_event)

        refute outdated_ibm_notes_event.gobierto_event_outdated?

        assert_no_difference 'GobiertoPeople::PersonEvent.count' do
          CalendarIntegration.sync_event(outdated_ibm_notes_event)
        end
      end

      def test_sync_creates_updates_and_removes_location_for_existing_gobierto_event
        ibm_notes_event = create_ibm_notes_event(location: nil)

        CalendarIntegration.sync_event(ibm_notes_event)

        assert ibm_notes_event.gobierto_event.locations.empty?

        ibm_notes_event.location = 'Location name added afterwards'

        CalendarIntegration.sync_event(ibm_notes_event)

        assert 'Location name added afterwards', ibm_notes_event.gobierto_event.locations.first.name

        ibm_notes_event.location = 'Location name updated afterwards'

        CalendarIntegration.sync_event(ibm_notes_event)

        assert 'Location name updated afterwards', ibm_notes_event.gobierto_event.locations.first.name

        ibm_notes_event.location = nil

        CalendarIntegration.sync_event(ibm_notes_event)

        assert ibm_notes_event.gobierto_event.locations.empty?
      end

    end
  end
end
