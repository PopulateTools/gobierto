# frozen_string_literal: true

class AddPrimaryKeyToGplanCategoriesNodes < ActiveRecord::Migration[5.2]
  def change
    add_column :gplan_categories_nodes, :id, :primary_key
  end
end
