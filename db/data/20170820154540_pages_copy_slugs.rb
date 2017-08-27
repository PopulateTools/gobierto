# frozen_string_literal: true

class PagesCopySlugs < ActiveRecord::Migration[5.1]
  def self.up
    GobiertoCms::Page.all.each do |page|
      page.update_column :slug, page.slug_translations["es"] || page.slug_translations["en"]
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
