# frozen_string_literal: true

require "test_helper"

module GobiertoCalendars
  class EventFormTest < ActiveSupport::TestCase

    def site
      @site ||= sites(:madrid)
    end

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def attendees
      @attendees ||= gobierto_people_people(:nelson, :tamara, :juana).map { |attendee| EventAttendee.new(person: attendee) }
    end

    def calendar
      gobierto_common_collections(:richard_calendar)
    end

    def existing_event
      @existing_event ||= gobierto_calendars_events(:richard_published)
    end

    def valid_attributes
      @valid_attributes ||= {
        external_id: "wadus",
        site_id: site.id,
        person_id: person.id,
        title_translations: { es: "Nuevo evento", en: "New event" },
        description_translations: { es: "<span>Descripción de <b>nuevo evento</b></span>", en: "<span><b>New event</b> description</span>" },
        description_source_translations: { es: "<span>Descripción de <b>nuevo evento</b></span>", en: "<span><b>New event</b> description</span>" },
        starts_at: 1.day.from_now,
        ends_at: 2.days.from_now,
        notify: false,
        attendees: attendees
      }
    end

    def test_create_with_valid_attributes
      form = EventForm.new(valid_attributes)
      assert form.save

      event = form.event
      assert event.persisted?
      assert event.slug.present?
      event_attendees = event.attendees.map(&:person)
      attendees.each do |attendee|
        assert event_attendees.include? attendee.person
      end

      expected = {
        "es" => "Descripción de nuevo evento",
        "en" => "New event description"
      }
      assert_equal expected, event.description_translations
    end

    def test_update_with_valid_attributes
      test_slug = "test-slug-wadus-event"
      form = EventForm.new(valid_attributes.merge(slug: test_slug))
      assert form.save

      event = form.event
      assert event.persisted?
      assert_equal test_slug, event.slug
    end

    def test_update_not_including_slug
      initial_slug = existing_event.slug
      form = EventForm.new(valid_attributes.merge(id: existing_event.id))
      assert form.save

      event = form.event
      assert event.persisted?
      assert_equal initial_slug, event.slug
    end

    def test_update_with_blank_string_slug
      initial_slug = existing_event.slug
      ["", " "].each do |blank_string|
        form = EventForm.new(valid_attributes.merge(id: existing_event.id, slug: blank_string))
        assert form.save

        event = form.event
        assert event.persisted?
        assert_equal initial_slug, event.slug
      end
    end
  end
end
