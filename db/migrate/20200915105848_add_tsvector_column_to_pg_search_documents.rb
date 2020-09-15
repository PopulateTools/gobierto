# frozen_string_literal: true

class AddTsvectorColumnToPgSearchDocuments < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      ALTER TABLE pg_search_documents
      ADD COLUMN content_tsvector tsvector GENERATED ALWAYS AS (
        to_tsvector('simple', f_unaccent(coalesce(content, '')))
      ) STORED;
    SQL
  end

  def down
    remove_column :pg_search_documents, :content_tsvector
  end
end
