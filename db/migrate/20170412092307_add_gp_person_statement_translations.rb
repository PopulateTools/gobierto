# frozen_string_literal: true

class AddGpPersonStatementTranslations < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_person_statements, :title_translations, :jsonb
    add_index :gp_person_statements, :title_translations, using: :gin
  end
end
