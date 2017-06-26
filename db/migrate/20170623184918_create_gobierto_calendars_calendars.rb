class CreateGobiertoCalendarsCalendars < ActiveRecord::Migration[5.1]
  def change
    create_table :gobierto_calendars_calendars do |t|
      t.belongs_to :owner, polymorphic: true, index: true
      t.string :name, null: false
      t.timestamps
    end
  end
end
