class UpdateSectionItemsItemId < ActiveRecord::Migration[5.1]
  def change
    change_column :gcms_section_items, :item_id, :string
  end
end
