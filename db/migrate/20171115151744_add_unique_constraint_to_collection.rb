# frozen_string_literal: true

class AddUniqueConstraintToCollection < ActiveRecord::Migration[5.1]
  def change
    remove_index :collections, name: "index_collections_on_container_type_and_container_id"
    add_index :collections, [:container_id, :container_type, :item_type], unique: true, name: "index_collections_on_container_and_item_type"
  end
end
