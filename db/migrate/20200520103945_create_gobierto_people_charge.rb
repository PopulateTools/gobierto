# frozen_string_literal: true

class CreateGobiertoPeopleCharge < ActiveRecord::Migration[5.2]
  def change
    create_table :gp_charges do |t|
      t.belongs_to :person, null: false
      t.belongs_to :department, null: false
      t.jsonb :name_translations
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
