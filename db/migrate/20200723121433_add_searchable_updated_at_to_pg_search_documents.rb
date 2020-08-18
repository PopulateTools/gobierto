# frozen_string_literal: true

class AddSearchableUpdatedAtToPgSearchDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :pg_search_documents, :searchable_updated_at, :datetime
  end
end
