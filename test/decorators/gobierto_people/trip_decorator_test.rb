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
        fixture_item = gobierto_people_trips(:richard_multiple_destinations)
        fixture_item.update_attribute(:meta, fixture_item.meta.merge(
          "company" => "Member 1, Member 2\nMember 3\nMember 3,member fourMember five"
        ))
        fixture_item
      end
    end

    def test_company_members
      expected_members = [
        "Member 1",
        "Member 2",
        "Member 3",
        "member four",
        "Member five"
      ]

      assert_equal expected_members, @subject.company_members
    end

  end
end
