require "test_helper"

class GobiertoPeople::PersonEventAttendeeTest < ActiveSupport::TestCase
  def person_event_attendee
    @person_event_attendee ||= gobierto_people_person_event_attendees(:tamara_richard_published)
  end

  def custom_person_event_attendee
    @custom_person_event_attendee ||= gobierto_people_person_event_attendees(:custom)
  end

  def test_valid
    assert person_event_attendee.valid?
    assert custom_person_event_attendee.valid?
  end
end
