class ChangeGobiertoPeoplePersonCalendarConfigurationDataDefaultValue < ActiveRecord::Migration[5.0]
  def change
    change_column_default :gp_person_calendar_configurations, :data, {}
  end
end
