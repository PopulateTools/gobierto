class AddParentCodeToBudgetCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :gb_categories, :parent_code, :string
  end
end
