class RenameOrganizationAddressColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :sites, :organization_email, :reply_to_email
  end
end
