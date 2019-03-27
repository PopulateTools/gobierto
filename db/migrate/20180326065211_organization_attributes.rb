# frozen_string_literal: true

class OrganizationAttributes < ActiveRecord::Migration[5.2]
  def change
    # Rename columns
    rename_column :sites, :municipality_id, :organization_id
    rename_column :sites, :location_name, :organization_name
    rename_column :sites, :institution_url, :organization_url
    rename_column :sites, :institution_type, :organization_type
    rename_column :sites, :institution_email, :organization_email
    rename_column :sites, :institution_address, :organization_address
    rename_column :sites, :institution_document_number, :organization_document_number

    # Remove columns
    remove_column :sites, :external_id
    remove_column :sites, :location_type

    # Change column type
    change_column :sites, :organization_id, :string
  end
end
