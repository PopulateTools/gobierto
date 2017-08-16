# frozen_string_literal: true

class CreateGobiertoBudgetConsultationsConsultations < ActiveRecord::Migration[5.0]
  def change
    create_table :gbc_consultations do |t|
      t.string :title, null: false, default: ""
      t.text :description, null: false, default: ""
      t.date :opens_on
      t.date :closes_on
      t.integer :visibility_level, null: false, default: 0
      t.decimal :budget_amount, precision: 8, scale: 2, null: false, default: 0.0

      t.references :admin
      t.references :site

      t.timestamps
    end
  end
end
