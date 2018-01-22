# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class PersonEventFormTest < ActiveSupport::TestCase

    def site
      @site ||= sites(:madrid)
    end

    def event
      @event ||= gobierto_calendars_events(:richard_published)
    end

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def event_attributes
      @event_attributes ||= {
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
      }
    end

    def valid_event_form
      @valid_event_form ||= PersonEventForm.new(event_attributes)
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

    def test_save_event_out_of_sync_range
      very_future_date = ::GobiertoCalendars.sync_range_end + 1.day
      very_old_date    = ::GobiertoCalendars.sync_range_start - 1.day

      very_future_event = PersonEventForm.new(event_attributes.merge(starts_at: very_future_date))
      very_old_event    = PersonEventForm.new(event_attributes.merge(starts_at: very_old_date))

      refute very_future_event.save
      refute very_old_event.save
    end

    def test_destroy
      valid_event_form.save

      assert_difference "GobiertoCalendars::Event.count", -1 do
        valid_event_form.destroy
      end
    end
  end
end
