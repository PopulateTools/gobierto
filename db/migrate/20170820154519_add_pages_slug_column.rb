# frozen_string_literal: true

class AddPagesSlugColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :gcms_pages, :slug, :string, null: false, default: ""
  end
end
