require "test_helper"

class GobiertoPeople::PersonTest < ActiveSupport::TestCase
  def person
    @person ||= gobierto_people_people(:richard)
  end

  def test_valid
    assert person.valid?
  end
end
