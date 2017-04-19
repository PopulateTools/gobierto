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

      def new_ibm_notes_event
        @new_ibm_notes_event ||= ::IbmNotes::PersonEvent.new(person, {
          'id' => 'Ibm Notes new event ID',
          'summary' => 'Ibm Notes new event summary',
          'start' =>  { 'date' => '2017-04-11', 'time' => '10:00:00', 'utc' => true },
          'end'   =>  { 'date' => '2017-04-11', 'time' => '11:00:00', 'utc' => true },
          'transparency' => 'transparent'
        })
      end

      def new_private_ibm_notes_event
        @new_private_ibm_notes_event ||= ::IbmNotes::PersonEvent.new(person, {
          'id' => 'Ibm Notes new private event ID',
          'summary' => 'Ibm Notes new private event summary',
          'start' =>  { 'date' => '2017-04-11', 'time' => '10:00:00', 'utc' => true },
          'end'   =>  { 'date' => '2017-04-11', 'time' => '11:00:00', 'utc' => true },
          'transparency' => 'opaque'
        })
      end

      def outdated_ibm_notes_event
        @outdated_ibm_notes_event ||= ::IbmNotes::PersonEvent.new(person, {
          'id' => 'Ibm Notes outdated event ID',
          'summary' => 'Ibm Notes outdated event title - THIS HAS CHANGED',
          'start' =>  { 'date' => '2017-04-11', 'time' => '10:00:00', 'utc' => true },
          'end'   =>  { 'date' => '2017-04-11', 'time' => '11:00:00', 'utc' => true },
          'transparency' => 'opaque'
        })
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

      def test_sync_creates_new_event
        refute new_ibm_notes_event.has_gobierto_event?

        CalendarIntegration.sync_event(new_ibm_notes_event)

        refute new_ibm_notes_event.gobierto_event_outdated?
        assert new_ibm_notes_event.has_gobierto_event?

        assert new_ibm_notes_event.gobierto_event.title, new_ibm_notes_event.title
        assert new_ibm_notes_event.gobierto_event.person, person
      end

      def test_sync_updates_existing_event
        assert outdated_ibm_notes_event.gobierto_event_outdated?

        CalendarIntegration.sync_event(outdated_ibm_notes_event)

        updated_gobierto_event = outdated_ibm_notes_event.gobierto_event

        refute outdated_ibm_notes_event.gobierto_event_outdated?
        assert updated_gobierto_event.title, 'Ibm Notes outdated event title - THIS HAS CHANGED'
        refute updated_gobierto_event.published?
      end

      def test_sync_doesnt_create_duplicated_events
        assert outdated_ibm_notes_event.gobierto_event_outdated?

        CalendarIntegration.sync_event(outdated_ibm_notes_event)

        refute outdated_ibm_notes_event.gobierto_event_outdated?

        assert_no_difference 'GobiertoPeople::PersonEvent.count' do
          CalendarIntegration.sync_event(outdated_ibm_notes_event)
        end
      end

      def test_sync_doesnt_import_new_private_events

        assert_no_difference 'GobiertoPeople::PersonEvent.count' do
          CalendarIntegration.sync_event(new_private_ibm_notes_event)
        end
      end

    end
  end
end
