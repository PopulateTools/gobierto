require "test_helper"

module GobiertoCalendars
  class EventLocationTest < ActiveSupport::TestCase
    def event_location
      @event_location ||= gobierto_calendars_event_locations(:madrid_city_council)
    end

    def test_valid
      assert event_location.valid?
    end
  end
end
