class ChangeGobiertoCommonCollectionItem < ActiveRecord::Migration[5.1]
  def change
    remove_reference :collection_items, :site
    add_reference :collection_items, :collection
  end
end
