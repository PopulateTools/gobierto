require "test_helper"

class GobiertoCalendars::CalendarTest < ActiveSupport::TestCase
  def calendar
    @calendar ||= GobiertoCalendars::Calendar.new
  end

  def test_valid
    assert calendar.valid?
  end
end
