require 'test_helper'

module GobiertoPeople
  module LotusNotes
    class CalendarIntegrationTest < ActiveSupport::TestCase

      def setup
        super
        outdated_lotus_event_gobierto_event.save!
      end

      def utc_time(date)
        d = Time.parse(date)
        Time.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def new_lotus_event
        @new_lotus_event ||= ::LotusNotes::PersonEvent.new(person, {
          'id' => 'Lotus Notes new event ID',
          'summary' => 'Lotus Notes new event summary',
          'start' =>  { 'date' => '2017-04-11', 'time' => '10:00:00', 'utc' => true },
          'end'   =>  { 'date' => '2017-04-11', 'time' => '11:00:00', 'utc' => true },
          'transparency' => 'transparent',
        })
      end

      def outdated_lotus_event
        @outdated_lotus_event ||= ::LotusNotes::PersonEvent.new(person, {
          'id' => 'Lotus Notes outdated event ID',
          'summary' => 'Lotus Notes outdated event title - THIS HAS CHANGED',
          'start' =>  { 'date' => '2017-04-11', 'time' => '10:00:00', 'utc' => true },
          'end'   =>  { 'date' => '2017-04-11', 'time' => '11:00:00', 'utc' => true },
          'transparency' => 'opaque'
        })
      end

      def outdated_lotus_event_gobierto_event
        @outdated_lotus_event_gobierto_event ||= GobiertoPeople::PersonEvent.new(
          external_id: 'Lotus Notes outdated event ID',
          title: 'Lotus Notes outdated event title',
          starts_at: utc_time("2017-04-11 10:00:00"),
          ends_at:   utc_time("2017-04-11 11:00:00"),
          state: GobiertoPeople::PersonEvent.states['published'],
          person: person
        )
      end

      def test_sync_creates_new_event
        refute new_lotus_event.has_gobierto_event?

        CalendarIntegration.sync_event(new_lotus_event)

        refute new_lotus_event.gobierto_event_outdated?
        assert new_lotus_event.has_gobierto_event?

        assert new_lotus_event.gobierto_event.title, new_lotus_event.title
        assert new_lotus_event.gobierto_event.person, person
      end

      def test_sync_updates_existing_event
        assert outdated_lotus_event.gobierto_event_outdated?

        CalendarIntegration.sync_event(outdated_lotus_event)

        updated_gobierto_event = outdated_lotus_event.gobierto_event

        refute outdated_lotus_event.gobierto_event_outdated?
        assert updated_gobierto_event.title, 'Lotus Notes outdated event title - THIS HAS CHANGED'
        refute updated_gobierto_event.published?
      end

    end
  end
end
