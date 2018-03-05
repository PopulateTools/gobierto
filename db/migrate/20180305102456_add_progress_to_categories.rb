# frozen_string_literal: true

class AddProgressToCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :gplan_categories, :progress, :float
    add_column :gplan_categories, :uid, :string
  end
end
