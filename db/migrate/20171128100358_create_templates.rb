# frozen_string_literal: true

class CreateTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :templates do |t|
      t.string :template_path

      t.timestamps
    end
  end
end
