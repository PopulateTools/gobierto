# frozen_string_literal: true

require "test_helper"

class GobiertoPeople::ClearImportedPersonEventsJobTest < ActiveSupport::TestCase
  def person
    @person ||= gobierto_people_people(:richard)
  end

  def test_perform
    event1 = gobierto_calendars_events(:richard_published)
    event1.update_column(:external_id, "richard_published")

    GobiertoPeople::ClearImportedPersonEventsJob.new.perform(person)

    assert_nil GobiertoCalendars::Event.find_by(id: event1.id)
  end
end
