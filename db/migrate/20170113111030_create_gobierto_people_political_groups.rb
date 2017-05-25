# frozen_string_literal: true

class CreateGobiertoPeoplePoliticalGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :gp_political_groups do |t|
      t.string :name, null: false, default: ''
      t.references :site
      t.references :admin

      t.timestamps
    end
  end
end
