# frozen_string_literal: true

class RenameUsersSourceSiteColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :source_site_id, :site_id
  end
end
