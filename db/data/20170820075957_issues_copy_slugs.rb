# frozen_string_literal: true

class IssuesCopySlugs < ActiveRecord::Migration[5.1]
  def self.up
    Issue.all.each do |issue|
      issue.update_column :slug, issue.slug_translations["es"]
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
