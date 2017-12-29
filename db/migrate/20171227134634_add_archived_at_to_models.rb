# frozen_string_literal: true

class AddArchivedAtToModels < ActiveRecord::Migration[5.1]
  def change
    add_column :gcms_pages, :archived_at, :datetime
    add_index :gcms_pages, :archived_at
  end
end
