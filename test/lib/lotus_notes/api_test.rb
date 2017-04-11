require 'test_helper'

class ApiTest < ActiveSupport::TestCase

  def calendar_endpoint
    ENV['LOTUS_SAMPLE_ENDPOINT']
  end

  def test_get_person_events
    VCR.use_cassette('sample_calendar_events', decode_compressed_response: true) do
      events = LotusNotes::Api.get_person_events(calendar_endpoint)
      event = events.first

      assert_equal events.size, 50

      assert_equal event['id'], 'D94D30773D262E53C12580FE00387295-Lotus_Notes_Generated'
      assert_equal event['summary'], 'Amadeu'
      assert_equal event['start'], { 'date' => '2017-04-11', 'time' => '10:00:00', 'utc' => true }
      assert_equal event['end'],   { 'date' => '2017-04-11', 'time' => '11:00:00', 'utc' => true }
      assert_equal event['transparency'], 'opaque'
    end
  end

end
