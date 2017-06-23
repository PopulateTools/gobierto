require "test_helper"
require "support/concerns/user/subscribable_test"
require "support/concerns/gobierto_common/sluggable_test"

module GobiertoPeople
  class PersonTest < ActiveSupport::TestCase
    include User::SubscribableTest
    include GobiertoCommon::SluggableTestModule

    def person
      @person ||= gobierto_people_people(:richard)
    end
    alias subscribable person

    def new_person
      ::GobiertoPeople::Person.create!(name: 'Person Name', site: sites(:madrid))
    end
    alias create_sluggable new_person

    def test_valid
      assert person.valid?
    end
  end
end
