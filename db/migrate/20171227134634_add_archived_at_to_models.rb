# frozen_string_literal: true

class AddArchivedAtToModels < ActiveRecord::Migration[5.1]
  def change
    add_column :gcms_pages, :archived_at, :datetime
    add_index :gcms_pages, :archived_at
    add_column :gc_events, :archived_at, :datetime
    add_index :gc_events, :archived_at
    add_column :ga_attachments, :archived_at, :datetime
    add_index :ga_attachments, :archived_at
    add_column :gpart_contribution_containers, :archived_at, :datetime
    add_index :gpart_contribution_containers, :archived_at
    add_column :gpart_polls, :archived_at, :datetime
    add_index :gpart_polls, :archived_at
  end
end
