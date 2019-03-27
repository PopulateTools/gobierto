# frozen_string_literal: true

class AddSiteIdToTranslations < ActiveRecord::Migration[5.1]
  def change
    add_column :translations, :site_id, :integer
    add_foreign_key :translations, :sites
  end
end
