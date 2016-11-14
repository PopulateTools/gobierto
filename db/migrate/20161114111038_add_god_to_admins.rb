class AddGodToAdmins < ActiveRecord::Migration[5.0]
  def change
    add_column :admins, :god, :boolean, null: false, default: false
  end
end
