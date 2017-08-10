class AddContainerAndTypeToGobiertoCommonCollection < ActiveRecord::Migration[5.1]
  def change
    add_reference :collections, :container, polymorphic: true, index: true
    add_column :collections, :item_type, :string
  end
end
