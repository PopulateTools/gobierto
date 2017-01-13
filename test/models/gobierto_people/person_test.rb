require "test_helper"

module GobiertoPeople
  class PersonTest < ActiveSupport::TestCase
    def person
      @person ||= gobierto_people_people(:richard)
    end

    def test_valid
      assert person.valid?
    end
  end
end
