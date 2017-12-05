# frozen_string_literal: true

class CreateTemplate < ActiveRecord::Migration[5.1]
  def up
    unless ::GobiertoCore::Template.any?
      ::GobiertoCore::Template.create!(template_path: "gobierto_participation/welcome/index.liquid")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
