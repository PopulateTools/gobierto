# frozen_string_literal: true

class AddTrigramIndexToPgSearchDocuments < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE INDEX pg_search_documents_on_content_idx ON pg_search_documents USING gin (content gin_trgm_ops);
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX pg_search_documents_on_content_idx;
    SQL
  end
end
