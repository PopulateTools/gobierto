# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"
require "factories/gobierto_people/factory"

module GobiertoPeople
  class DepartmentTest < ActiveSupport::TestCase

    include EventHelpers

    def department
      @department ||= gobierto_people_departments(:culture_department)
    end

    def clear_fixtures
      GobiertoPeople::Person.delete_all
      GobiertoPeople::Trip.delete_all
      GobiertoPeople::Gift.delete_all
      GobiertoPeople::Invitation.delete_all
    end

    def test_short_name
      I18n.locale = :ca

      expected_result = {
        "Departamento de Wadus" => "Wadus",
        "Department of Wadus" => "Wadus",
        "Departament de la Wadus" => "Wadus",
        "Departament de la Foo i d'Bar i Baz" => "Foo i Bar i Baz",
        "Departament de Wadus" => "Wadus",
        "Departament d'Wadus" => "Wadus"
      }

      expected_result.keys.each.each do |full_name|
        department.update!(name: full_name)
        assert_equal expected_result[full_name], department.short_name
      end
    end

    def test_filter_department_people_linked_through_events
      clear_fixtures

      old_department_member = GobiertoPeople::Factory.person
      department_member = GobiertoPeople::Factory.person(name: "Alice")

      create_event(person: old_department_member, department: department, starts_at: :past)
      create_event(person: department_member, department: department, starts_at: :future)

      assert_equal [old_department_member], department.people(to_date: Time.current)
      assert_equal [department_member], department.people(from_date: Time.current)
    end

    def test_department_people_linked_through_trips
      clear_fixtures

      old_department_member = GobiertoPeople::Factory.person
      department_member = GobiertoPeople::Factory.person(name: "Alice")

      GobiertoPeople::Factory.trip(person: old_department_member, start_date: 1.year.ago, end_date: 1.year.ago + 1.day)
      GobiertoPeople::Factory.trip(person: department_member, start_date: 1.day.from_now, end_date: 2.days.from_now)

      assert_equal [old_department_member], department.people(to_date: Time.current)
      assert_equal [department_member], department.people(from_date: Time.current)
    end

    def test_department_people_linked_through_invitations
      clear_fixtures

      old_department_member = GobiertoPeople::Factory.person
      department_member = GobiertoPeople::Factory.person(name: "Alice")

      GobiertoPeople::Factory.invitation(person: old_department_member, start_date: 1.year.ago, end_date: 1.year.ago + 1.day)
      GobiertoPeople::Factory.invitation(person: department_member, start_date: 1.day.from_now, end_date: 2.days.from_now)

      assert_equal [old_department_member], department.people(to_date: Time.current)
      assert_equal [department_member], department.people(from_date: Time.current)
    end

    def test_department_people_linked_through_gifts
      clear_fixtures

      old_department_member = GobiertoPeople::Factory.person
      department_member = GobiertoPeople::Factory.person(name: "Alice")

      GobiertoPeople::Factory.gift(person: old_department_member, date: 1.year.ago)
      GobiertoPeople::Factory.gift(person: department_member, date: 1.day.from_now)

      assert_equal [old_department_member], department.people(to_date: Time.current)
      assert_equal [department_member], department.people(from_date: Time.current)
    end

  end
end
