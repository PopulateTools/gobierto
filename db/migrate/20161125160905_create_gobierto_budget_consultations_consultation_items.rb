# frozen_string_literal: true

class CreateGobiertoBudgetConsultationsConsultationItems < ActiveRecord::Migration[5.0]
  def change
    create_table :gbc_consultation_items do |t|
      t.string :title, null: false, default: ''
      t.text :description
      t.string :budget_line_id, null: false, default: ''
      t.decimal :budget_line_amount, precision: 8, scale: 2, null: false, default: 0.0
      t.integer :position, null: false, default: 0
      t.references :consultation

      t.timestamps
    end
  end
end
