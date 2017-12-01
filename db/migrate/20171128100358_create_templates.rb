# frozen_string_literal: true

class CreateTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :gcore_templates do |t|
      t.string :template_path

      t.timestamps
    end
  end
end
