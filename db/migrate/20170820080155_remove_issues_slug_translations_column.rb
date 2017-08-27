# frozen_string_literal: true

class RemoveIssuesSlugTranslationsColumn < ActiveRecord::Migration[5.1]
  def up
    remove_column :issues, :slug_translations
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
