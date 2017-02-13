class AddInternalIdToContentBlocks < ActiveRecord::Migration[5.0]
  def change
    add_column :content_blocks, :internal_id, :string
    add_index :content_blocks, [:site_id, :internal_id], unique: true
  end
end
