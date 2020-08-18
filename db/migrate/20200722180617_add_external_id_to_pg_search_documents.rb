# frozen_string_literal: true

class AddExternalIdToPgSearchDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :pg_search_documents, :external_id, :string
  end
end
