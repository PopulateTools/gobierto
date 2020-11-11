# frozen_string_literal: true

class AddIndexToTsvectorColumn < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :pg_search_documents, :content_tsvector, using: :gin, algorithm: :concurrently
  end
end
