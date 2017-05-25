# frozen_string_literal: true

require 'test_helper'

module GobiertoPeople
  class PersonGoogleCalendarCalendarsFormTest < ActiveSupport::TestCase
    def valid_form
      @valid_form ||= GobiertoPeople::PersonGoogleCalendarCalendarsForm.new(
        person_id: person.id,
        calendars: %w[foo bar]
      )
    end

    def site
      @site ||= sites(:madrid)
    end

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def test_save_with_valid_attributes
      assert valid_form.save

      configuration = ::GobiertoPeople::PersonGoogleCalendarConfiguration.find_by(person_id: person.id)
      assert_equal %w[foo bar], configuration.calendars
    end

    def test_update_with_valid_attributes
      configuration = ::GobiertoPeople::PersonGoogleCalendarConfiguration.find_by(person_id: person.id)
      configuration.calendars = ['foo']
      configuration.save!

      assert valid_form.save

      configuration = ::GobiertoPeople::PersonGoogleCalendarConfiguration.find_by(person_id: person.id)
      assert_equal %w[foo bar], configuration.calendars
    end
  end
end
