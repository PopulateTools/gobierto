# frozen_string_literal: true

class DropIssuesAndScopes < ActiveRecord::Migration[5.2]
  def up
    [:issues, :scopes].each do |table|
      drop_table table
    end
  end

  def down
    [:issues, :scopes].each do |table|
      create_table table do |t|
        t.references :site
        t.jsonb :name_translations
        t.jsonb :description_translations
        t.integer :position, default: 0, null: false
        t.string :slug, default: "", null: false

        t.timestamps
      end
    end
  end
end
