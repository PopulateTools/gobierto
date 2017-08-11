# frozen_string_literal: true

class GobiertoAdminPrefixTableNames < ActiveRecord::Migration[5.0]
  def change
    rename_table :admins, :admin_admins
    rename_table :admin_sites, :admin_admin_sites
  end
end
