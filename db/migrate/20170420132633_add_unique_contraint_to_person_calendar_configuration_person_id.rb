class AddUniqueContraintToPersonCalendarConfigurationPersonId < ActiveRecord::Migration[5.0]
  def change
    add_index :gp_person_calendar_configurations, :person_id, unique: true
  end
end
