# frozen_string_literal: true

class CreateGobiertoPeoplePeople < ActiveRecord::Migration[5.0]
  def change
    create_table :gp_people do |t|
      t.references :site
      t.references :admin
      t.string :name, null: false, default: ""
      t.string :charge
      t.text :bio
      t.string :bio_url
      t.integer :visibility_level, null: false, default: 0

      t.timestamps
    end
  end
end
