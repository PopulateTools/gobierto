# frozen_string_literal: true

class RemoveExtensionLiquidOfTheTemplates < ActiveRecord::Migration[5.1]
  def up
    GobiertoCore::Template.all.each do |template|
      template.update_column :template_path, template.template_path.chomp(".liquid")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
