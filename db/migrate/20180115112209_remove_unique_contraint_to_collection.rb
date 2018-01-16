# frozen_string_literal: true

class RemoveUniqueContraintToCollection < ActiveRecord::Migration[5.1]
  def change
    remove_index :collections, name: "index_collections_on_container_and_item_type"
  end
end
