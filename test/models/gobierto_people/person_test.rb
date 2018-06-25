# frozen_string_literal: true

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
      ::GobiertoPeople::Person.create!(name: "Person Name", site: sites(:madrid))
    end
    alias create_sluggable new_person

    def test_valid
      assert person.valid?
    end

    def test_collection_is_created
      person = ::GobiertoPeople::Person.create!(name: "New Person Name", site: sites(:madrid))
      assert person.events_collection.present?
    end

    def test_to_url
      assert_equal "http://#{person.site.domain}/personas/#{person.slug}", person.to_url
    end
  end
end
