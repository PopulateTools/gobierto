# frozen_string_literal: true

class CreateGobiertoCommonContentBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :content_blocks do |t|
      t.references :site
      t.string :content_model_name, null: false, default: ''
      t.text :title
    end

    add_index :content_blocks, :content_model_name
  end
end
