# frozen_string_literal: true

require "test_helper"

module GobiertoCalendars
  class GoogleCalendarCalendarsFormTest < ActiveSupport::TestCase

    def valid_form
      @valid_form ||= GoogleCalendarCalendarsForm.new(
        person_id: person.id,
        calendars: %w(foo bar)
      )
    end

    def site
      @site ||= sites(:madrid)
    end

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def calendar
      gobierto_common_collections(:richard_calendar)
    end

    def test_save_with_valid_attributes
      assert valid_form.save

      configuration = GoogleCalendarConfiguration.find_by(collection: calendar)
      assert_equal %w(foo bar), configuration.calendars
    end

    def test_update_with_valid_attributes
      configuration = GoogleCalendarConfiguration.find_by(collection: calendar)
      configuration.calendars = ["foo"]
      configuration.save!

      assert valid_form.save

      configuration = GoogleCalendarConfiguration.find_by(collection: calendar)
      assert_equal %w(foo bar), configuration.calendars
    end

  end
end
