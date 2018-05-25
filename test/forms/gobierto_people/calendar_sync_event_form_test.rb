# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"

module GobiertoPeople
  class CalendarSyncEventFormTest < ActiveSupport::TestCase

    include ::EventHelpers

    def site
      @site ||= sites(:madrid)
    end

    def event
      @event ||= gobierto_calendars_events(:richard_published)
    end

    def richard
      @richard ||= gobierto_people_people(:richard)
    end
    alias person richard

    def tamara
      @tamara ||= gobierto_people_people(:tamara)
    end

    def nelson
      @nelson ||= gobierto_people_people(:nelson)
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
      @valid_event_form ||= CalendarSyncEventForm.new(event_attributes)
    end

    def invalid_event_form
      @invalid_event_form ||= CalendarSyncEventForm.new(
        external_id: nil,
        site_id: site.id,
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
      assert_equal 1, invalid_event_form.errors.messages[:external_id].size
      assert_equal 1, invalid_event_form.errors.messages[:title].size
      assert_equal 1, invalid_event_form.errors.messages[:ends_at].size
    end

    def test_save_event_out_of_sync_range
      very_future_date = ::GobiertoCalendars.sync_range_end + 1.day
      very_old_date    = ::GobiertoCalendars.sync_range_start - 1.day

      very_future_event = CalendarSyncEventForm.new(event_attributes.merge(starts_at: very_future_date))
      very_old_event    = CalendarSyncEventForm.new(event_attributes.merge(starts_at: very_old_date))

      refute very_future_event.save
      refute very_old_event.save
    end

    def test_destroy
      valid_event_form.save

      assert_difference "GobiertoCalendars::Event.count", -1 do
        valid_event_form.destroy
      end
    end

    def test_scopes_event_search_on_person_when_external_id_collides
      event_1 = create_event(person: richard, title: 'Richard event', external_id: '123')
      event_2 = create_event(person: tamara,  title: 'Tamara event',  external_id: '123')
      event_3 = create_event(person: nelson,  title: 'Nelson event',  external_id: '123')

      # permutate order of all three events so test never passes by accident
      event_3_form = CalendarSyncEventForm.new(site_id: site.id, person_id: nelson.id,  external_id: '123')
      event_1_form = CalendarSyncEventForm.new(site_id: site.id, person_id: richard.id, external_id: '123')
      event_2_form = CalendarSyncEventForm.new(site_id: site.id, person_id: tamara.id,  external_id: '123')

      assert_equal 'Richard event', event_1_form.event.title
      assert_equal 'Tamara event',  event_2_form.event.title
      assert_equal 'Nelson event',  event_3_form.event.title
    end

  end
end
