class LinkCalendarConfigurationsToCollections < ActiveRecord::Migration[5.1]

  def up
    rename_table :gp_person_calendar_configurations, :gc_calendar_configurations

    change_column :gc_calendar_configurations, :person_id, :integer, null: true
    remove_index :gc_calendar_configurations, name: 'index_gc_calendar_configurations_on_person_id'

    add_column :gc_calendar_configurations, :collection_id, :bigint
    add_column :gc_calendar_configurations, :integration_name, :string
  end

  def down
    rename_table :gc_calendar_configurations, :gp_person_calendar_configurations

    change_column :gp_person_calendar_configurations, :person_id, :integer, null: false
    add_index :gp_person_calendar_configurations, :person_id, unique: true

    remove_column :gp_person_calendar_configurations, :collection_id
    remove_column :gp_person_calendar_configurations, :integration_name
  end

end
