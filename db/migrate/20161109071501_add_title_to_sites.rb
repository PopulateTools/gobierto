class AddTitleToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :title, :string, null: false, default: ""
  end
end
