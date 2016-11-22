class CreateAdminCensusImports < ActiveRecord::Migration[5.0]
  def change
    create_table :admin_census_imports do |t|
      t.references :admin
      t.references :site
      t.integer :imported_records, null: false, default: 0
      t.boolean :completed, null: false, default: false

      t.timestamps
    end
  end
end
