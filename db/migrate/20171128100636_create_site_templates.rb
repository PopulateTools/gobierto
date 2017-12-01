# frozen_string_literal: true

class CreateSiteTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :gcore_site_templates do |t|
      t.text :markup
      t.references :template
      t.references :site

      t.timestamps
    end
  end
end
