require "test_helper"

module GobiertoPeople
  class PersonDecoratorTest < ActiveSupport::TestCase
    def setup
      super
      @subject = PersonDecorator.new(person)
    end

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def test_contact_methods
      expected_contact_methods = {
        email: "",
        twitter: { handle: "", url: "" },
        facebook: { handle: "", url: "" },
        linkedin: { handle: "", url: "" }
      }

      assert_equal expected_contact_methods, @subject.contact_methods
    end
  end
end
