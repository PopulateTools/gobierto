# frozen_string_literal: true

class ChangeParentIdSectionItemsColumn < ActiveRecord::Migration[6.0]
  def up
    change_column :gcms_section_items, :parent_id, :integer, null: true
  end

  def down
    change_column :gcms_section_items, :parent_id, :integer, null: false
  end
end
