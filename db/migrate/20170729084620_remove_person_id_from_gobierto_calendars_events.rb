class RemovePersonIdFromGobiertoCalendarsEvents < ActiveRecord::Migration[5.1]
  def up
    remove_column :gobierto_calendars_events, :person_id
    #remove_index :gobierto_calendars_events, name: "index_gobierto_calendars_events_on_person_id"
    #remove_index :gobierto_calendars_events, name: "index_gobierto_calendars_events_on_person_id_and_external_id"
  end

  def down
    add_column :gobierto_calendars_events, :person_id, :integer, null: false
    #add_index :gobierto_calendars_events, :person_id, name: "index_gobierto_calendars_events_on_person_id"
    #add_index :gobierto_calendars_events, [:person_id, :external_id], unique: true, name: "index_gobierto_calendars_events_on_person_id_and_external_id"
  end
end
