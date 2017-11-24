class LinkCalendarConfigurationsToCollections < ActiveRecord::Migration[5.1]

  def change
    rename_table :gp_person_calendar_configurations, :gc_calendar_configurations
    rename_column :gc_calendar_configurations, :person_id, :collection_id
    add_column :gc_calendar_configurations, :integration_name, :string
  end

end
