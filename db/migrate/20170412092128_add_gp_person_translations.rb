# frozen_string_literal: true

class AddGpPersonTranslations < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_people, :charge_translations, :jsonb
    add_column :gp_people, :bio_translations, :jsonb

    add_index :gp_people, :charge_translations, using: :gin
    add_index :gp_people, :bio_translations, using: :gin
  end
end
