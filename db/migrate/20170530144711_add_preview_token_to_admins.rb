# frozen_string_literal: true

class AddPreviewTokenToAdmins < ActiveRecord::Migration[5.1]
  def up
    add_column :admin_admins, :preview_token, :string
    GobiertoAdmin::Admin.reset_column_information
    generate_preview_token_for_existing_admins
    change_column :admin_admins, :preview_token, :string, null: false
    add_index :admin_admins, :preview_token, unique: true
  end

  def down
    remove_index :admin_admins, :preview_token
    remove_column :admin_admins, :preview_token
  end

  private

  def generate_preview_token_for_existing_admins
    GobiertoAdmin::Admin.where(preview_token: nil).each do |admin|
      admin.send(:generate_preview_token)
      admin.save!
    end
  end
end
