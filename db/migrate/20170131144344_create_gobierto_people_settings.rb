# frozen_string_literal: true

class CreateGobiertoPeopleSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :gp_settings do |t|
      t.references :site
      t.string :key, null: false, default: ""
      t.string :value, null: false, default: ""

      t.timestamps
    end
  end
end
