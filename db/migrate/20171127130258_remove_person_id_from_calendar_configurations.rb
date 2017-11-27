class RemovePersonIdFromCalendarConfigurations < ActiveRecord::Migration[5.1]

  def change
    remove_column :gc_calendar_configurations, :person_id
    change_column :gc_calendar_configurations, :collection_id, :bigint, null: false
    change_column :gc_calendar_configurations, :integration_name, :string, null: false
    add_index :gc_calendar_configurations, :collection_id, unique: true
  end

end
