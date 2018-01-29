# frozen_string_literal: true

class CreateGobiertoPlansModels < ActiveRecord::Migration[5.1]
  def change
    create_table :gplan_plan_types do |t|
      t.string :name

      t.timestamps
    end

    create_table :gplan_plans do |t|
      t.jsonb :title_translations
      t.jsonb :description_translations
      t.integer :year
      t.jsonb :configuration_data
      t.references :plan_type
      t.references :site
      t.string :slug, null: false, default: ""

      t.timestamps
    end

    add_index :gplan_plans, :title_translations, using: :gin

    create_table :gplan_categories do |t|
      t.jsonb :name_translations
      t.integer :level, default: 0, null: false
      t.integer :parent_id, null: false
      t.references :plan
      t.string :slug, null: false, default: ""

      t.timestamps
    end

    add_index :gplan_categories, :name_translations, using: :gin

    create_table :gplan_nodes do |t|
      t.jsonb :name_translations
      t.float :progress
      t.jsonb :status_translations
      t.date :starts_at
      t.date :ends_at
      t.jsonb :options

      t.timestamps
    end

    add_index :gplan_nodes, :name_translations, using: :gin

    create_table :gplan_categories_nodes, id: false do |t|
      t.integer :category_id
      t.integer :node_id
    end

    add_index :gplan_categories_nodes, :category_id
    add_index :gplan_categories_nodes, :node_id
  end
end
