class CreateGcmsPagesTable < ActiveRecord::Migration[5.0]
  def change
    create_table :gcms_pages do |t|
      t.string :title, null: false, default: ''
      t.text :body, null: false, default: ''
      t.string :slug, null: false, default: ''
      t.references :site
      t.integer :visibility_level, null: false, default: 0

      t.timestamps
    end

    add_index :gcms_pages, [:slug, :site_id], unique: true
  end
end
