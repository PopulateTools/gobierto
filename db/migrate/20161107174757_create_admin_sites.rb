class CreateAdminSites < ActiveRecord::Migration[5.0]
  def change
    create_table :admin_sites do |t|
      t.references :admin, index: true
      t.references :site, index: true
    end

    add_index :admin_sites, [:admin_id, :site_id]
  end
end
