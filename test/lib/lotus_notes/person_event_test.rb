require 'test_helper'

class ApiTest < ActiveSupport::TestCase

  def setup
    super
    gobierto_event.save!
  end

  def person
    @person ||= gobierto_people_people(:richard)
  end

  def utc_time(date)
    d = Time.parse(date)
    Time.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
  end

  def response_event
    @response_event ||= {
      'id' => 'Lotus Notes persisted event ID',
      'summary' => 'Lotus Notes persisted event title',
      'start' =>  { 'date' => '2017-04-11', 'time' => '10:00:00', 'utc' => true },
      'end'   =>  { 'date' => '2017-04-11', 'time' => '11:00:00', 'utc' => true },
      'transparency' => 'transparent',
    }
  end

  def lotus_event
    @lotus_event ||= LotusNotes::PersonEvent.new(person, response_event)
  end

  def gobierto_event
    @gobierto_event ||= GobiertoPeople::PersonEvent.new(
      external_id: 'Lotus Notes persisted event ID',
      title: 'Lotus Notes persisted event title',
      starts_at: utc_time("2017-04-11 10:00:00"),
      ends_at:   utc_time("2017-04-11 11:00:00"),
      state: GobiertoPeople::PersonEvent.states['published'],
      person: person
    )
  end

  def new_response_event
    @new_response_event ||= {
      'id' => 'Lotus Notes new event ID',
      'summary' => 'Lotus Notes new event summary',
      'start' =>  { 'date' => '2017-04-11', 'time' => '10:00:00', 'utc' => true },
      'end'   =>  { 'date' => '2017-04-11', 'time' => '11:00:00', 'utc' => true },
      'transparency' => 'transparent',
    }
  end

  def new_lotus_event
    @new_lotus_event ||= LotusNotes::PersonEvent.new(person, new_response_event)
  end

  def replacement_lotus_event
    @replacement_lotus_event ||= LotusNotes::PersonEvent.new(person, {
      'id' => 'Lotus Notes outdated event ID',
      'summary' => 'Lotus Notes outdated event title - THIS HAS CHANGED',
      'start' =>  { 'date' => '2017-04-11', 'time' => '10:00:00', 'utc' => true },
      'end'   =>  { 'date' => '2017-04-11', 'time' => '11:00:00', 'utc' => true },
      'transparency' => 'opaque'
    })
  end

  def outdated_gobierto_event
    @outdated_gobierto_event ||= GobiertoPeople::PersonEvent.new(
      external_id: 'Lotus Notes outdated event ID',
      title: 'Lotus Notes outdated event title',
      starts_at: utc_time("2017-04-11 10:00:00"),
      ends_at:   utc_time("2017-04-11 11:00:00"),
      state: GobiertoPeople::PersonEvent.states['published'],
      person: person
    )
  end

  def test_initialize
    assert_equal lotus_event.external_id, 'Lotus Notes persisted event ID'
    assert_equal lotus_event.title, 'Lotus Notes persisted event title'
    assert_equal lotus_event.state, GobiertoPeople::PersonEvent.states['published']
    assert_equal lotus_event.transparency, 'transparent'
    assert_equal lotus_event.person, person
    assert_equal lotus_event.starts_at, utc_time('2017-04-11 10:00:00')
    assert_equal lotus_event.ends_at,   utc_time('2017-04-11 11:00:00')
  end

  def test_hash_version
    assert_equal(lotus_event.hash_version, {
      'title' => 'Lotus Notes persisted event title',
      'starts_at' => '2017-04-11T10:00:00.000Z',
      'ends_at'   => '2017-04-11T11:00:00.000Z',
      'state' => GobiertoPeople::PersonEvent.states['published'],
    })
  end

  def test_sync_creates_gobierto_event_for_new_lotus_notes_events
    new_lotus_event.sync

    assert new_lotus_event.has_gobierto_event?
    assert new_lotus_event.gobierto_event.title, new_lotus_event.title
    assert new_lotus_event.gobierto_event.person, person
  end

  def test_sync_updates_gobierto_event_for_outdated_lotus_notes_events
    outdated_gobierto_event.save!

    assert replacement_lotus_event.has_gobierto_event?
    assert replacement_lotus_event.gobierto_event_outdated?

    replacement_lotus_event.sync
    updated_gobierto_event = replacement_lotus_event.gobierto_event

    # TODO: refute replacement_lotus_event.gobierto_event_outdated?
    assert updated_gobierto_event.title, 'Lotus Notes outdated event title - THIS HAS CHANGED'
    refute updated_gobierto_event.published?
  end

  def test_gobierto_event
    assert_equal lotus_event.gobierto_event, gobierto_event
    assert_equal new_lotus_event.gobierto_event, nil
  end

  def test_has_gobierto_event?
    assert lotus_event.has_gobierto_event?
    refute new_lotus_event.has_gobierto_event?
  end

end
