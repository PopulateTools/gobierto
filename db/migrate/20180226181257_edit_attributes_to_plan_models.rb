# frozen_string_literal: true

class EditAttributesToPlanModels < ActiveRecord::Migration[5.1]
  def up
    remove_column :gplan_plans, :title_for_menu_translations
    remove_column :gplan_plan_types, :archived_at
    remove_column :gplan_plan_types, :name
    add_column :gplan_plan_types, :name_translations, :jsonb
    add_column :gplan_plan_types, :site_id, :integer
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
