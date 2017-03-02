class CreateGobiertoCommonCustomUserFields < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')

    create_table :custom_user_fields do |t|
      t.references :site
      t.integer :position, null: false, default: 0
      t.hstore :title
      t.boolean :mandatory, default: false
      t.integer :field_type, null: false, default: 0
      t.jsonb :options
      t.string :name, default: "", null: false

      t.timestamps
    end

    add_index :custom_user_fields, [:site_id, :name], unique: true
  end
end
