# frozen_string_literal: true

class ScopesCreateSlugs < ActiveRecord::Migration[5.1]
  def up
    GobiertoCommon::Scope.all.each do |scope|
      scope.update_column :slug, scope.attributes_for_slug.join("-").tr("_", " ").parameterize
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
