class AddBudgetLineNameToConsultationItems < ActiveRecord::Migration[5.0]
  def change
    add_column :gbc_consultation_items, :budget_line_name, :string, null: false, default: ""
  end
end
