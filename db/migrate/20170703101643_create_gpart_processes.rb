# frozen_string_literal: true

class CreateGpartProcesses < ActiveRecord::Migration[5.1]
  def change
    create_table :gpart_processes do |t|
      t.references :site
      t.string :slug, null: false, default: ""
      t.integer :visibility_level, null: false, default: 0
      t.jsonb :title_translations
      t.jsonb :body_translations
      t.jsonb :slug_translations
      t.date :starts
      t.date :ends
      t.timestamps
    end

    add_index :gpart_processes, :title_translations, using: :gin
    add_index :gpart_processes, :body_translations, using: :gin
    add_index :gpart_processes, :slug_translations, using: :gin
  end
end
