# frozen_string_literal: true

class AddDescriptionToIssues < ActiveRecord::Migration[5.1]
  def change
    add_column :issues, :description_translations, :jsonb
    Issue.update_all(description_translations: { "en": "Description", "es": "Descripción" })
  end
end
