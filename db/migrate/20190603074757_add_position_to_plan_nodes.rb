class AddPositionToPlanNodes < ActiveRecord::Migration[5.2]
  def change
    add_column :gplan_nodes, :position, :integer, default: nil
    add_index :gplan_nodes, :position
  end
end
