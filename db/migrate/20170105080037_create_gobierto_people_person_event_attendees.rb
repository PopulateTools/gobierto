class CreateGobiertoPeoplePersonEventAttendees < ActiveRecord::Migration[5.0]
  def change
    create_table :gp_person_event_attendees do |t|
      t.string :name
      t.string :charge
      t.references :person
      t.references :person_event

      t.timestamps
    end
  end
end
