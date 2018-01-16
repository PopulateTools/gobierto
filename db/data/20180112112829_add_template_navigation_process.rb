# frozen_string_literal: true

class AddTemplateNavigationProcess < ActiveRecord::Migration[5.1]
  def up
    ::GobiertoCore::Template.create!(template_path: "gobierto_participation/layouts/navigation_process.liquid")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
