# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class PersonEventFormTest < ActiveSupport::TestCase
    def valid_event_form
      @valid_event_form ||= PersonEventForm.new(
        external_id: "123",
        site_id: site.id,
        person_id: person.id,
        title: event.title,
        description: event.description,
        starts_at: event.starts_at,
        ends_at: event.ends_at,
        state: event.state,
        locations: [],
        attendees: []
      )
    end

    def invalid_recurring_event_form
      @valid_event_form ||= PersonEventForm.new(
        external_id: "123",
        site_id: site.id,
        person_id: person.id,
        title: event.title,
        description: event.description,
        starts_at: 4.months.from_now,
        ends_at: 4.months.from_now,
        state: event.state,
        locations: [],
        attendees: [],
        recurring: true
      )
    end

    def invalid_event_form
      @invalid_event_form ||= PersonEventForm.new(
        external_id: nil,
        site_id: nil,
        person_id: nil,
        title: nil,
        description: nil,
        starts_at: nil,
        ends_at: nil,
        state: nil,
        locations: [],
        attendees: []
      )
    end

    def site
      @site ||= sites(:madrid)
    end

    def event
      @event ||= gobierto_calendars_events(:richard_published)
    end

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def test_save_with_valid_attributes
      assert valid_event_form.save
    end

    def test_error_messages_with_invalid_attributes
      invalid_event_form.save

      assert_equal 1, invalid_event_form.errors.messages[:collection].size
      assert_equal 1, invalid_event_form.errors.messages[:site].size
      assert_equal 1, invalid_event_form.errors.messages[:external_id].size
      assert_equal 1, invalid_event_form.errors.messages[:title].size
      assert_equal 1, invalid_event_form.errors.messages[:ends_at].size
    end

    def test_error_messages_with_invalid_recurring_event
      invalid_recurring_event_form.save

      assert_equal 1, invalid_recurring_event_form.errors.messages[:starts_at].size
    end
  end
end
