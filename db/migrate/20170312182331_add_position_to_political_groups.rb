# frozen_string_literal: true

class AddPositionToPoliticalGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_political_groups, :position, :integer, default: 0, null: false
    add_index :gp_political_groups, :position
  end
end
