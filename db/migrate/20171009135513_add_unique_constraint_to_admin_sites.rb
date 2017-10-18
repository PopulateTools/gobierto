class AddUniqueConstraintToAdminSites < ActiveRecord::Migration[5.1]
  def change
    add_index :admin_admin_sites, [:site_id, :admin_id], unique: true
  end
end
