class CreateTableGobiertoModuleSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :gobierto_module_settings do |t|
      t.references :site, index: true
      t.string :module_name
      t.jsonb :settings

      t.timestamps
    end

    add_index :gobierto_module_settings, [:site_id, :module_name], unique: true
  end
end
