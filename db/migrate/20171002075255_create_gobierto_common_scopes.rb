class CreateGobiertoCommonScopes < ActiveRecord::Migration[5.1]

  def change
    create_table :scopes do |t|
      t.bigint :site_id, null: false
      t.jsonb :name_translations, null: false
      t.jsonb :description_translations, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_column :gpart_processes, :scope_id, :bigint
  end

end
