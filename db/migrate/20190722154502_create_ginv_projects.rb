# frozen_string_literal: true

class CreateGinvProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :ginv_projects do |t|
      t.references :site, index: true
      t.jsonb :title_translations
      t.string :external_id

      t.timestamps
    end
  end
end
