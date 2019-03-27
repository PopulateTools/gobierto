# frozen_string_literal: true

class ChangeColumnNullOfParentIdOnCategories < ActiveRecord::Migration[5.1]
  def change
    change_column_null(:gplan_categories, :parent_id, true)
  end
end
