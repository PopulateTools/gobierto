# frozen_string_literal: true

require 'test_helper'

module GobiertoPeople
  class PersonIbmNotesCalendarConfigurationTest < ActiveSupport::TestCase

    def calendar
      gobierto_common_collections(:nelson_calendar)
    end

    def test_ibm_notes_url
      configuration = ::GobiertoCalendars::IbmNotesCalendarConfiguration.create!(
        collection: calendar,
        integration_name: 'ibm_notes',
        data: { ibm_notes_usr: 'wadus' }
      )

      configuration.ibm_notes_url = 'http://calendar/nelson'
      configuration.save!

      configuration = ::GobiertoCalendars::IbmNotesCalendarConfiguration.find_by(collection: calendar)

      assert_equal 'http://calendar/nelson', configuration.ibm_notes_url
    end

  end
end
