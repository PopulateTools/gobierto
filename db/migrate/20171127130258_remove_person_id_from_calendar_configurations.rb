class RemovePersonIdFromCalendarConfigurations < ActiveRecord::Migration[5.1]

  def up
    remove_column :gc_calendar_configurations, :person_id
    change_column :gc_calendar_configurations, :collection_id, :bigint, null: false
    change_column :gc_calendar_configurations, :integration_name, :string, null: false
    add_index :gc_calendar_configurations, :collection_id, unique: true
  end

  def down
    add_column :gc_calendar_configurations, :person_id, :bigint
    change_column :gc_calendar_configurations, :collection_id, :bigint, null: true
    change_column :gc_calendar_configurations, :integration_name, :string, null: true
    remove_index :gc_calendar_configurations, name: 'index_gc_calendar_configurations_on_collection_id'
  end

end
