# frozen_string_literal: true

class CreateGobiertoCitizensChartersEditions < ActiveRecord::Migration[5.2]
  def change
    create_table :gcc_editions do |t|
      t.references :commitment, index: true
      t.integer :period_interval, null: false, default: 0
      t.datetime :period
      t.decimal :percentage
      t.decimal :value
      t.decimal :max_value

      t.timestamps
    end
  end
end
