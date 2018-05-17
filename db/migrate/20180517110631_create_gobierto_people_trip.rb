# frozen_string_literal: true

class CreateGobiertoPeopleTrip < ActiveRecord::Migration[5.2]

  def change
    create_table :gp_trips do |t|
      t.belongs_to :person, null: false
      t.string :title, null: false
      t.string :description
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.jsonb :destinations_meta
      t.jsonb :meta
    end
  end

end
