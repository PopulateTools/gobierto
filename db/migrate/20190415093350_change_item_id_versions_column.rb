# frozen_string_literal: true

class ChangeItemIdVersionsColumn < ActiveRecord::Migration[5.2]
  def up
    change_column :versions, :item_id, :integer, limit: 8
  end

  def down
    change_column :versions, :item_id, :integer, limit: nil
  end
end
