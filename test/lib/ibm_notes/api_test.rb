require 'test_helper'
require_relative '../../../lib/ibm_notes/api'

class ApiTest < ActiveSupport::TestCase

  def test_get_person_events
    VCR.use_cassette('ibm_notes/calendar_events_ok', decode_compressed_response: true) do
      events = IbmNotes::Api.get_person_events(
        endpoint: 'https://host.wadus.com/endpoint',
        username: 'Mo',
        password: 'Cuishle'
      )

      event = events.first

      assert_equal events.size, 4

      assert_equal event['id'], 'Ibm Notes public event ID'
      assert_equal event['summary'], 'Ibm Notes public event summary'
      assert_equal event['location'], 'Ibm Notes public event location'
      assert_equal event['start'], { 'date' => '2017-04-11', 'time' => '10:00:00', 'utc' => true }
      assert_equal event['end'],   { 'date' => '2017-04-11', 'time' => '11:00:00', 'utc' => true }
    end
  end

  def test_get_person_events_with_invalid_credentials
    assert_raises ::IbmNotes::InvalidCredentials do
      VCR.use_cassette('ibm_notes/calendar_events_invalid_credentials', decode_compressed_response: true) do
        IbmNotes::Api.get_person_events(
          endpoint: 'https://host.wadus.com/endpoint',
          username: 'INVALID',
          password: 'INVALID'
        )
      end
    end
  end

  def test_get_person_events_with_no_events
    VCR.use_cassette('ibm_notes/calendar_events_no_events', decode_compressed_response: true) do
      IbmNotes::Api.get_person_events(
        endpoint: 'https://host.wadus.com/endpoint?since=2013-07-01T00:00:00Z&before=2013-07-31T00:00:00Z',
        username: 'Mo',
        password: 'Cuishle'
      )
    end
  end

  def test_get_person_events_json_parser_error
    assert_raises JSON::ParserError do
      VCR.use_cassette('ibm_notes/calendar_events_json_parser_error', decode_compressed_response: true) do
        IbmNotes::Api.get_person_events(
          endpoint: 'https://host.wadus.com/endpoint',
          username: 'Mo',
          password: 'Cuishle'
        )
      end
    end
  end

end
