class AddBodySourceToCmsPages < ActiveRecord::Migration[5.1]
  def change
    add_column :gcms_pages, :body_source_translations, :jsonb
    add_index :gcms_pages, :body_source_translations, using: :gin
  end
end
