# frozen_string_literal: true

class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :external_id
      t.string :name
      t.string :domain, unique: true
      t.text :configuration_data
      t.string :location_name
      t.string :location_type
      t.string :institution_url
      t.string :institution_type
      t.string :institution_email
      t.string :institution_address
      t.string :institution_document_number

      t.timestamps null: false
    end
  end
end
