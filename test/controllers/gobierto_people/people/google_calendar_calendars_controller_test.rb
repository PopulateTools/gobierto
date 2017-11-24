# frozen_string_literal: true

require "test_helper"

class GobiertoPeople::People::GoogleCalendar::CalendarsControllerTest < ActionController::TestCase
  def site
    @site ||= sites(:madrid)
  end

  def person
    @person ||= gobierto_people_people(:richard)
  end

  def test_update
    ApplicationController.stub_any_instance(:current_site, site) do
      put :update, params: { person_slug: person.slug, person_id: person.id, calendars_form: { calendars: ["foo", "bar", ""] } }, session: { google_calendar_person_id: person.id }
      assert_response :redirect

      configuration = GobiertoCalendars::GoogleCalendarConfiguration.find_by(collection: person.calendar)
      assert_equal %w(foo bar), configuration.calendars
    end
  end
end
