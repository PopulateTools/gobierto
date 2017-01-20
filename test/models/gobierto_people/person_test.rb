require "test_helper"
require "support/concerns/user/subscribable_test"

module GobiertoPeople
  class PersonTest < ActiveSupport::TestCase
    include User::SubscribableTest

    def person
      @person ||= gobierto_people_people(:richard)
    end
    alias subscribable person

    def test_valid
      assert person.valid?
    end
  end
end
