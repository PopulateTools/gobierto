class UpdateGobiertoCommonCollectionItem < ActiveRecord::Migration[5.1]
  def change
    remove_column :collection_items, :site_id
    add_column :collection_items, :collection_id, :bigint
    add_index :collection_items, :collection_id
  end
end
