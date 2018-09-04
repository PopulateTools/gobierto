# frozen_string_literal: true

require "test_helper"
require "support/concerns/user/subscribable_test"
require "support/concerns/gobierto_common/sluggable_test"

module GobiertoPeople
  class PersonStatementTest < ActiveSupport::TestCase
    include User::SubscribableTest
    include GobiertoCommon::SluggableTestModule

    def madrid
      @madrid ||= sites(:madrid)
    end

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def person_statement
      @person_statement ||= gobierto_people_person_statements(:richard_current)
    end
    alias richard_statement person_statement
    alias subscribable person_statement

    def richard_past_statement
      @richard_past ||= gobierto_people_person_statements(:richard_past)
    end

    def nelson_statement
      @nelson_statement ||= gobierto_people_person_statements(:nelson_current)
    end

    def tamara_statement
      @tamara_statement ||= gobierto_people_person_statements(:tamara_current)
    end

    def new_person_statement
      GobiertoPeople::PersonStatement.create!(
        title: "Person Statement Title",
        published_on: Time.zone.now,
        person: gobierto_people_people(:richard),
        site: sites(:madrid)
      )
    end
    alias create_sluggable new_person_statement

    def test_valid
      assert person_statement.valid?
    end

    def test_sorted_by_person_scope
      sorted_statements_ids = madrid.person_statements.active.sorted_by_person_position.pluck(:id)

      # should be ordered by person position, and within the same person recent statements appear first
      assert_equal [richard_statement.id, richard_past_statement.id, nelson_statement.id, tamara_statement.id], sorted_statements_ids
    end

    def test_public?
      assert person_statement.public?

      person.draft!

      refute person_statement.public?

      person_statement.draft!

      refute person_statement.public?

      person.active!

      refute person_statement.public?
    end

  end
end
