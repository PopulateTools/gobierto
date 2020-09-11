# frozen_string_literal: true

class CreatePgSearchDocuments < ActiveRecord::Migration[5.2]
  def self.up
    say_with_time("Creating table for pg_search multisearch") do
      create_table :pg_search_documents do |t|
        t.text :content
        t.belongs_to :searchable, polymorphic: true, index: true
        t.belongs_to :site, index: true
        t.string :resource_path
        t.jsonb :title_translations
        t.jsonb :description_translations
        t.jsonb :meta
        t.timestamps null: false
      end
    end
  end

  def self.down
    say_with_time("Dropping table for pg_search multisearch") do
      drop_table :pg_search_documents
    end
  end
end
