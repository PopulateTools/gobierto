class CreateGobiertoBudgetsBudgetLineFeedbacks < ActiveRecord::Migration[5.1]
  def change
    create_table :gb_budget_line_feedbacks do |t|
      t.references :site, index: true
      t.integer :year
      t.string :budget_line_id
      t.integer :answer1
      t.integer :answer2
      t.timestamps
    end
  end
end
