# frozen_string_literal: true

class AddArchivedAtToGobiertoCitizensChartersEditions < ActiveRecord::Migration[5.2]
  def change
    add_column :gcc_editions, :archived_at, :datetime
    add_index :gcc_editions, :archived_at
  end
end
