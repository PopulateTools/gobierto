# frozen_string_literal: true

class AddVisibilityLevelToGobiertoPlansNodes < ActiveRecord::Migration[5.2]
  def change
    add_column :gplan_nodes, :visibility_level, :integer, null: false, default: 0

    GobiertoPlans::Node.update_all(visibility_level: 1)
  end
end
