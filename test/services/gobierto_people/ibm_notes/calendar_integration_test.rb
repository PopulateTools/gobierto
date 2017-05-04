require 'test_helper'

module GobiertoPeople
  module IbmNotes
    class CalendarIntegrationTest < ActiveSupport::TestCase

      def setup
        super
        outdated_ibm_notes_event_gobierto_event.save!
      end

      def utc_time(date)
        d = Time.parse(date)
        Time.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def create_ibm_notes_event(params = {})
        ::IbmNotes::PersonEvent.new((params[:person] || person), {
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
          person: person
        )
      end

      def test_sync_creates_new_event_with_location
        refute new_ibm_notes_event.has_gobierto_event?

        CalendarIntegration.sync_event(new_ibm_notes_event)

        refute new_ibm_notes_event.gobierto_event_outdated?
        assert new_ibm_notes_event.has_gobierto_event?

        gobierto_event = new_ibm_notes_event.gobierto_event

        assert_equal new_ibm_notes_event.title, gobierto_event.title
        assert_equal person, gobierto_event.person

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
