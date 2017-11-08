# frozen_string_literal: true

class ChangeGobiertoCommonCollectionSlug < ActiveRecord::Migration[5.1]
  def change
    remove_column :collections, :slug_translations
    add_column :collections, :slug, :string, null: false, default: ""
  end
end
