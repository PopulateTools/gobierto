# frozen_string_literal: true

require "test_helper"

class IbmNotes::PersonEventTest < ActiveSupport::TestCase
  def setup
    super
    persisted_ibm_notes_event_gobierto_event.save!
  end

  def person
    @person ||= gobierto_people_people(:richard)
  end

  def utc_time(date)
    d = Time.parse(date)
    Time.utc(d.year, d.month, d.day, d.hour, d.min, d.sec)
  end

  def response_data(params = {})
    {
      "id"       => params[:id] || "Ibm Notes event ID",
      "summary"  => params[:summary] || "Ibm Notes event title",
      "location" => params.has_key?(:location) ? params[:location] : "Ibm Notes event location",
      "start"    => params[:start] || { "date" => "2017-04-11", "time" => "10:00:00", "utc" => true },
      "end"      => params[:end] || { "date" => "2017-04-11", "time" => "11:00:00", "utc" => true }
    }
  end

  def persisted_ibm_notes_event_response_data
    @persisted_ibm_notes_event_response_data ||= response_data(
      id: "Ibm Notes persisted event ID",
      summary: "Ibm Notes persisted event title"
    )
  end

  def persisted_ibm_notes_event
    @persisted_ibm_notes_event ||= IbmNotes::PersonEvent.new(person, persisted_ibm_notes_event_response_data)
  end

  def persisted_ibm_notes_event_gobierto_event
    @persisted_ibm_notes_event_gobierto_event ||= GobiertoCalendars::Event.new(
      id: "Ibm Notes persisted event ID",
      title: "Ibm Notes persisted event title",
      starts_at: utc_time("2017-04-11 10:00:00"),
      ends_at:   utc_time("2017-04-11 11:00:00"),
      collection: person.events_collection,
      site: person.site
    )
  end

  def new_ibm_notes_event_response_data
    @new_ibm_notes_event_response_data ||= response_data(
      id: "Ibm Notes new event ID",
      summary: "Ibm Notes new event title"
    )
  end

  def new_ibm_notes_event
    @new_ibm_notes_event ||= IbmNotes::PersonEvent.new(person, new_ibm_notes_event_response_data)
  end

  def test_initialize
    assert_equal "Ibm Notes persisted event ID", persisted_ibm_notes_event.id
    assert_equal "Ibm Notes persisted event title", persisted_ibm_notes_event.title
    assert_equal person, persisted_ibm_notes_event.person
    assert_equal utc_time("2017-04-11 10:00:00"), persisted_ibm_notes_event.starts_at
    assert_equal utc_time("2017-04-11 11:00:00"), persisted_ibm_notes_event.ends_at
  end

  def test_parse_time_zones
    ibm_notes_event = IbmNotes::PersonEvent.new(person, response_data(start: { "date" => "2017-04-11", "time" => "10:00:00", "tzid" => "GMT+1 Standard Time" }))

    assert_equal utc_time("2017-04-11 08:00:00"), ibm_notes_event.starts_at
  end

  def test_parse_known_time_zones
    ibm_notes_event = IbmNotes::PersonEvent.new(person, response_data(start: { "date" => "2017-04-11", "time" => "10:00:00", "tzid" => "Europe/Lisbon" }))

    assert_equal utc_time("2017-04-11 10:00:00"), ibm_notes_event.starts_at
  end

  def test_parse_unknown_time_zone
    assert_raise do
      IbmNotes::PersonEvent.new(person, response_data(start: { "date" => "2017-04-11", "time" => "10:00:00", "tzid" => "Unkown" }))
    end
  end

  def test_parse_unknown_time_zone
    assert_equal "Ibm Notes persisted event ID", persisted_ibm_notes_event.id
    assert_equal "Ibm Notes persisted event title", persisted_ibm_notes_event.title
    assert_equal person, persisted_ibm_notes_event.person
    assert_equal utc_time("2017-04-11 10:00:00"), persisted_ibm_notes_event.starts_at
    assert_equal utc_time("2017-04-11 11:00:00"), persisted_ibm_notes_event.ends_at
  end

  def test_initialize_event_location
    ibm_notes_event = IbmNotes::PersonEvent.new(person, response_data(location: nil))

    assert_nil ibm_notes_event.location

    ibm_notes_event = IbmNotes::PersonEvent.new(person, response_data(location: ""))

    assert_nil ibm_notes_event.location

    ibm_notes_event = IbmNotes::PersonEvent.new(person, response_data(location: "valid location name"))

    assert_equal "valid location name", ibm_notes_event.location
  end
end
