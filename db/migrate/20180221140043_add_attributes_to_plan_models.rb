# frozen_string_literal: true

class AddAttributesToPlanModels < ActiveRecord::Migration[5.1]
  def change
    add_column :gplan_plans, :visibility_level, :integer, null: false, default: 0
    add_column :gplan_plans, :title_for_menu_translations, :jsonb
    rename_column :gplan_plans, :description_translations, :introduction_translations
    add_column :gplan_plans, :css, :text
    add_column :gplan_plans, :archived_at, :datetime
    add_index :gplan_plans, :archived_at
    add_column :gplan_plan_types, :slug, :string, null: false, default: ""
    add_column :gplan_plan_types, :archived_at, :datetime
    add_index :gplan_plan_types, :archived_at
  end
end
