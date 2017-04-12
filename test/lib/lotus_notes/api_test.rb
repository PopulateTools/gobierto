require 'test_helper'

class ApiTest < ActiveSupport::TestCase

  def test_get_person_events
    VCR.use_cassette('sample_calendar_events', decode_compressed_response: true) do
      events = LotusNotes::Api.get_person_events(
        endpoint: 'https://host.wadus.com/endpoint',
        username: 'Mo',
        password: 'Cuishle'
      )

      event = events.first

      assert_equal events.size, 3

      assert_equal event['id'], 'Lotus Notes public event ID'
      assert_equal event['summary'], 'Lotus Notes public event summary'
      assert_equal event['start'], { 'date' => '2017-04-11', 'time' => '10:00:00', 'utc' => true }
      assert_equal event['end'],   { 'date' => '2017-04-11', 'time' => '11:00:00', 'utc' => true }
      assert_equal event['transparency'], 'transparent'
    end
  end

end
