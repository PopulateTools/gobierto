require 'test_helper'

module GobiertoAdmin
  module GobiertoPeople
    class PersonCalendarConfigurationFormTest < ActiveSupport::TestCase

      def person
        gobierto_people_people(:richard)
      end

      def valid_person_calendar_configuration_form
        @valid_person_calendar_configuration_form ||= PersonCalendarConfigurationForm.new(
          person_id: person.id,
          ibm_notes_url: 'http://foo.com'
        )
      end

      def richard_calendar_configuration
        person.calendar_configuration
      end

      def test_save_with_valid_attributes
        assert valid_person_calendar_configuration_form.save
        assert_equal({ 'endpoint' => 'http://foo.com'}, person.calendar_configuration.data)
      end
    end
  end
end
