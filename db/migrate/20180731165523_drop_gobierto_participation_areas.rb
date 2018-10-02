# frozen_string_literal: true

class DropGobiertoParticipationAreas < ActiveRecord::Migration[5.2]
  def up
    drop_table :gpart_areas
  end

  def down
    create_table :gpart_areas do |t|
      t.references :site
      t.jsonb :name_translations
      t.jsonb :slug_translations

      t.timestamps
    end

    add_index :gpart_areas, :name_translations, using: :gin
    add_index :gpart_areas, :slug_translations, using: :gin
  end
end
