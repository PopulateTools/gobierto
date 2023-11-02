# frozen_string_literal: true

class CreateGobiertoCommonLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.string :external_id
      t.jsonb :meta
      t.string :names, array: true
    end
  end
end
