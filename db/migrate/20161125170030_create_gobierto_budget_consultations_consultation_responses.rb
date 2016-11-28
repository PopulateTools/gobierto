class CreateGobiertoBudgetConsultationsConsultationResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :gbc_consultation_responses do |t|
      t.references :consultation
      t.references :user
      t.text :consultation_items
      t.decimal :budget_amount, precision: 8, scale: 2
      t.integer :visibility_level, null: false, default: 0

      t.timestamps
    end
  end
end
