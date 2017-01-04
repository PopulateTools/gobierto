require "test_helper"

module GobiertoAdmin
  module GobiertoPeople
    class PersonEventFormTest < ActiveSupport::TestCase
      def valid_person_event_form
        @valid_person_event_form ||= PersonEventForm.new(
          person_id: person.id,
          title: person_event.title,
          description: person_event.description,
          attachment_url: person_event.attachment_url,
          starts_at: person_event.starts_at,
          ends_at: person_event.ends_at
        )
      end

      def invalid_person_event_form
        @invalid_person_event_form ||= PersonEventForm.new(
          person_id: nil,
          title: nil,
          description: nil,
          attachment_url: person_event.attachment_url,
          starts_at: nil,
          ends_at: nil
        )
      end

      def person_event
        @person_event ||= gobierto_people_person_events(:richard_approved)
      end

      def person
        @person ||= person_event.person
      end

      def test_save_with_valid_attributes
        assert valid_person_event_form.save
      end

      def test_error_messages_with_invalid_attributes
        invalid_person_event_form.save

        assert_equal 1, invalid_person_event_form.errors.messages[:person].size
        assert_equal 1, invalid_person_event_form.errors.messages[:title].size
        assert_equal 1, invalid_person_event_form.errors.messages[:starts_at].size
        assert_equal 1, invalid_person_event_form.errors.messages[:ends_at].size
      end
    end
  end
end
