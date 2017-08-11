# frozen_string_literal: true

class CreateGobiertoPeoplePersonEventLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :gp_person_event_locations do |t|
      t.string :name, null: false, default: ""
      t.string :address
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :lng, precision: 10, scale: 6
      t.references :person_event

      t.timestamps
    end
  end
end
