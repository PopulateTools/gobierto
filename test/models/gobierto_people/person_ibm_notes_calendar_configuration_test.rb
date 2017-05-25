# frozen_string_literal: true

require 'test_helper'

module GobiertoPeople
  class PersonIbmNotesCalendarConfigurationTest < ActiveSupport::TestCase
    def person
      gobierto_people_people(:nelson)
    end

    def test_endpoint
      configuration = PersonIbmNotesCalendarConfiguration.create(person: person)

      assert_equal({}, configuration.data)

      configuration.endpoint = 'http://calendar/nelson'
      configuration.save

      configuration = PersonIbmNotesCalendarConfiguration.find_by(person: person)

      assert_equal 'http://calendar/nelson', configuration.endpoint
    end
  end
end
