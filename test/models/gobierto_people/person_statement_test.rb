require "test_helper"
require "support/concerns/user/subscribable_test"

module GobiertoPeople
  class PersonStatementTest < ActiveSupport::TestCase
    include User::SubscribableTest

    def person_statement
      @person_statement ||= gobierto_people_person_statements(:richard_current)
    end
    alias subscribable person_statement

    def test_valid
      assert person_statement.valid?
    end
  end
end
