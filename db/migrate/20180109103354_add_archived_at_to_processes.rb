# frozen_string_literal: true

class AddArchivedAtToProcesses < ActiveRecord::Migration[5.1]
  def change
    add_column :gpart_processes, :archived_at, :datetime
    add_index :gpart_processes, :archived_at
  end
end
