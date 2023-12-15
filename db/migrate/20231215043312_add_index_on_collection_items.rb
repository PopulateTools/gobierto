class AddIndexOnCollectionItems < ActiveRecord::Migration[6.0]
  def change
    add_index :collection_items, [:container_type, :item_type, :item_id], name: 'index_collection_items_on_container_type_item_type_and_item_id'
  end
end
