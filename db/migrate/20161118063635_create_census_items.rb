class CreateCensusItems < ActiveRecord::Migration[5.0]
  def change
    create_table :census_items do |t|
      t.references :site
      t.string :document_number_digest, null: false, default: ""
      t.string :date_of_birth, null: false, default: ""
      t.integer :import_reference
      t.boolean :verified, null: false, default: false
    end

    add_index :census_items, [:site_id, :document_number_digest, :date_of_birth], name: "index_census_items_on_site_id_and_doc_number_and_date_of_birth"
    add_index :census_items, [:site_id, :document_number_digest, :date_of_birth, :verified], name: "index_census_items_on_site_id_and_doc_number_and_birth_verified"
    add_index :census_items, [:site_id, :import_reference], name: "index_census_items_on_site_id_and_import_reference"
  end
end
