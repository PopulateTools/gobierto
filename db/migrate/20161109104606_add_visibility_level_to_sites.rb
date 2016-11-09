class AddVisibilityLevelToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :visibility_level, :integer, null: false, default: 0
  end
end
