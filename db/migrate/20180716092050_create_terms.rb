# frozen_string_literal: true

class CreateTerms < ActiveRecord::Migration[5.2]
  def change
    create_table :terms do |t|
      t.references :vocabulary
      t.jsonb :name_translations
      t.jsonb :description_translations
      t.string :slug
      t.integer :position, null: false, default: 0
      t.integer :level, default: 0, null: false
      t.references :term

      t.timestamps
    end

    add_index :terms, [:slug, :vocabulary_id]
  end
end
