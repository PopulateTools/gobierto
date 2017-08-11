# frozen_string_literal: true

class IncreaseNumericPrecisionInAmountFields < ActiveRecord::Migration[5.0]
  def change
    change_column :gbc_consultation_items, :budget_line_amount, :decimal, precision: 12, scale: 2, null: false, default: 0.0
    change_column :gbc_consultation_responses, :budget_amount, :decimal, precision: 12, scale: 2, null: false, default: 0.0
    change_column :gbc_consultations, :budget_amount, :decimal, precision: 12, scale: 2, null: false, default: 0.0
  end
end
