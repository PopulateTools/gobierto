# frozen_string_literal: true

class CreateGdbDashboards < ActiveRecord::Migration[6.0]
  def change
    create_table :gdb_dashboards do |t|
      t.references :site, index: true
      t.jsonb :title_translations
      t.integer :visibility_level, null: false, default: 0
      t.string :context
      t.jsonb :widgets_configuration

      t.timestamps
    end
  end
end
