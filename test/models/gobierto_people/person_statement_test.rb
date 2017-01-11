require "test_helper"

module GobiertoPeople
  class PersonStatementTest < ActiveSupport::TestCase
    def person_statement
      @person_statement ||= gobierto_people_person_statements(:richard_current)
    end

    def test_valid
      assert person_statement.valid?
    end
  end
end
