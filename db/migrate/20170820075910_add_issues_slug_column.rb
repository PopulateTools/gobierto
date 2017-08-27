# frozen_string_literal: true

class AddIssuesSlugColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :issues, :slug, :string, null: false, default: ""
  end
end
