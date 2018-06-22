# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class TripDecoratorTest < ActiveSupport::TestCase

    def setup
      super
      @subject = TripDecorator.new(trip)
    end

    def trip
      @trip ||= begin
        fixture_item = gobierto_people_trips(:richard_multiple_destinations_recent)
        fixture_item.update_attribute(:meta, fixture_item.meta.merge(
          "company" => "Member 1  Member 2\nMember 2\nmember threeMember 4"
        ))
        fixture_item
      end
    end

    def test_company_members
      expected_members = [
        "Member 1",
        "Member 2",
        "member three",
        "Member 4"
      ]

      assert_equal expected_members, @subject.company_members
    end

  end
end
