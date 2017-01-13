require "test_helper"

class GobiertoPeople::PersonEventLocationTest < ActiveSupport::TestCase
  def person_event_location
    @person_event_location ||= gobierto_people_person_event_locations(:madrid_city_council)
  end

  def test_valid
    assert person_event_location.valid?
  end
end
