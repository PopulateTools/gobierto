class ChangeGobiertoCalendarsTablePrefix < ActiveRecord::Migration[5.1]

  def change
    rename_table :gobierto_calendars_event_attendees, :gc_event_attendees
    rename_table :gobierto_calendars_event_locations, :gc_event_locations
    rename_table :gobierto_calendars_events, :gc_events
  end

end
