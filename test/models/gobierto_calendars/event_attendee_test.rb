# frozen_string_literal: true

require "test_helper"

module GobiertoCalendars
  class EventAttendeeTest < ActiveSupport::TestCase
    def event_attendee
      @event_attendee ||= gobierto_calendars_event_attendees(:tamara_richard_published)
    end

    def custom_event_attendee
      @custom_event_attendee ||= gobierto_calendars_event_attendees(:custom)
    end

    def test_valid
      assert event_attendee.valid?
      assert custom_event_attendee.valid?
    end
  end
end
