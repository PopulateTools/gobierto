class RenameGpPersonEventsToGobiertoCalendarsEvents < ActiveRecord::Migration[5.1]
  def change
    rename_table :gp_person_events, :gobierto_calendars_events
  end
end
