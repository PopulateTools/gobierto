# frozen_string_literal: true

class CreateAttachings < ActiveRecord::Migration[5.1]
  def change
    create_table :ga_attachings do |t|
      t.integer :site_id, null: false
      t.integer :attachment_id, null: false
      t.integer :attachable_id, null: false
      t.string :attachable_type, null: false
    end

    add_index :ga_attachings, [:site_id, :attachment_id, :attachable_id, :attachable_type], unique: true, name: "record_unique_index"
  end
end
