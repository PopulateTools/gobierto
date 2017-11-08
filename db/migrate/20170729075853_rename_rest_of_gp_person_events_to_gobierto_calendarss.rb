# frozen_string_literal: true

class RenameRestOfGpPersonEventsToGobiertoCalendarss < ActiveRecord::Migration[5.1]
  def change
    rename_table :gp_person_event_attendees, :gobierto_calendars_event_attendees
    rename_table :gp_person_event_locations, :gobierto_calendars_event_locations

    rename_column :gobierto_calendars_event_attendees, :person_event_id, :event_id
    rename_column :gobierto_calendars_event_locations, :person_event_id, :event_id
  end
end
