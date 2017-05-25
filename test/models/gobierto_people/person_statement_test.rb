# frozen_string_literal: true

require 'test_helper'
require 'support/concerns/user/subscribable_test'
require 'support/concerns/gobierto_people/sluggable_test'

module GobiertoPeople
  class PersonStatementTest < ActiveSupport::TestCase
    include User::SubscribableTest
    include ::GobiertoPeople::SluggableTestModule

    def person_statement
      @person_statement ||= gobierto_people_person_statements(:richard_current)
    end
    alias subscribable person_statement

    def new_person_statement
      ::GobiertoPeople::PersonStatement.create!(
        title: 'Person Statement Title',
        published_on: Time.zone.now,
        person: gobierto_people_people(:richard),
        site: sites(:madrid)
      )
    end
    alias create_sluggable new_person_statement

    def test_valid
      assert person_statement.valid?
    end
  end
end
