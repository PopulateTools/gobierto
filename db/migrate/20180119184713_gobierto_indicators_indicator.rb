# frozen_string_literal: true

class GobiertoIndicatorsIndicator < ActiveRecord::Migration[5.1]
  def change
    create_table :gi_indicators do |t|
      t.string :name, null: false, default: ""
      t.date :year
      t.jsonb :indicator_response
      t.references :site

      t.timestamps
    end
  end
end
