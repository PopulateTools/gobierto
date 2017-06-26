require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonEventFormTest < ActiveSupport::TestCase
      def valid_event_form
        @valid_event_form ||= PersonEventForm.new(
          person_id: person.id,
          title_translations: {I18n.locale => event.title},
          description_translations: {I18n.locale => event.description},
          attachment_url: event.attachment_url,
          starts_at: event.starts_at,
          ends_at: event.ends_at,
          state: event.state,
          locations: [],
          attendees: []
        )
      end

      def invalid_event_form
        @invalid_event_form ||= PersonEventForm.new(
          person_id: nil,
          title_translations: {},
          description_translations: {},
          attachment_url: event.attachment_url,
          starts_at: nil,
          ends_at: nil,
          state: nil,
          locations: [],
          attendees: []
        )
      end

      def event
        @event ||= gobierto_calendars_events(:richard_published)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def collection
        @collection ||= person.events_collection
      end

      def test_save_with_valid_attributes
        assert valid_event_form.save
      end

      def test_error_messages_with_invalid_attributes
        invalid_event_form.save

        assert_equal 1, invalid_event_form.errors.messages[:person].size
        assert_equal 1, invalid_event_form.errors.messages[:collection].size
        assert_equal 1, invalid_event_form.errors.messages[:site].size
        assert_equal 1, invalid_event_form.errors.messages[:title_translations].size
        assert_equal 1, invalid_event_form.errors.messages[:ends_at].size
      end
    end
  end
end
