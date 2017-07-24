class CreateGobiertoCommonCollectionItem < ActiveRecord::Migration[5.1]
  def change
    create_table :collection_items do |t|
      t.belongs_to :collection
      t.belongs_to :item, polymorphic: true
      t.belongs_to :container, polymorphic: true
      t.timestamps
    end
  end
end
