# frozen_string_literal: true

require "test_helper"
require_relative "../../../lib/ibm_notes/api"

class ApiTest < ActiveSupport::TestCase
  def test_get_person_events
    VCR.use_cassette("ibm_notes/person_events_collection_v9", decode_compressed_response: true) do
      response_data = IbmNotes::Api.get_person_events(
        endpoint: "https://host.wadus.com/mail/foo.nsf/api/calendar/events",
        username: "username",
        password: "password"
      )

      events = response_data["events"]

      assert_equal events.size, 3
      assert_equal "/mail/foo.nsf/api/calendar/events/BD5EA243F9F715AAC1258116003ED56C-Lotus_Notes_Generated", events[0]["href"]
      assert_equal "/mail/foo.nsf/api/calendar/events/3C1E302CAC131891C12580F90044239B-Lotus_Notes_Generated", events[1]["href"]
      assert_equal "/mail/foo.nsf/api/calendar/events/D2E5B40E6AAEAED4C125808E0035A6A0-Lotus_Notes_Generated/20170503T073000Z", events[2]["href"]
    end
  end

  def test_get_event
    VCR.use_cassette("ibm_notes/non_recurrent_event", decode_compressed_response: true) do
      response_data = IbmNotes::Api.get_event(
        endpoint: "https://host.wadus.com/mail/foo.nsf/api/calendar/events/3C1E302CAC131891C12580F90044239B-Lotus_Notes_Generated",
        username: "username",
        password: "password"
      )

      event = response_data["events"][0]

      assert_equal "3C1E302CAC131891C12580F90044239B-Lotus_Notes_Generated", event["id"]
      assert_equal "Lliurament Premis Rac", event["summary"]
      assert_equal "2017-05-04", event["start"]["date"]
    end
  end

  def test_get_recurrent_event_instances
    VCR.use_cassette("ibm_notes/recurrent_event_instances", decode_compressed_response: true) do
      response_data = IbmNotes::Api.get_recurrent_event_instances(
        endpoint: "https://host.wadus.com/mail/bar.nsf/api/calendar/events/646503F7F545D629C12580FB0030DC5E_0-Lotus_ReadRange_Generated",
        username: "username",
        password: "password"
      )

      instances = response_data["instances"]

      assert_equal 9, instances.size
      assert_equal "20170303T110000Z", instances[0]["recurrenceId"]
      assert_equal "20170407T113000Z", instances[1]["recurrenceId"]
      assert_equal "20171201T110000Z", instances[8]["recurrenceId"]
    end
  end

  def test_get_person_events_with_invalid_credentials
    assert_raises ::IbmNotes::InvalidCredentials do
      VCR.use_cassette("ibm_notes/calendar_events_invalid_credentials", decode_compressed_response: true) do
        IbmNotes::Api.get_person_events(
          endpoint: "https://host.wadus.com/endpoint",
          username: "INVALID",
          password: "INVALID"
        )
      end
    end
  end

  def test_get_person_events_with_no_events
    VCR.use_cassette("ibm_notes/calendar_events_no_events", decode_compressed_response: true) do
      IbmNotes::Api.get_person_events(
        endpoint: "https://host.wadus.com/endpoint?since=2013-07-01T00:00:00Z&before=2013-07-31T00:00:00Z",
        username: "username",
        password: "password"
      )
    end
  end

  def test_get_person_events_json_parser_error
    assert_raises JSON::ParserError do
      VCR.use_cassette("ibm_notes/calendar_events_json_parser_error", decode_compressed_response: true) do
        IbmNotes::Api.get_person_events(
          endpoint: "https://host.wadus.com/endpoint",
          username: "username",
          password: "password"
        )
      end
    end
  end
end
