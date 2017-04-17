class AddGpPersonEventTranslations < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_person_events, :title_translations, :jsonb
    add_column :gp_person_events, :description_translations, :jsonb

    add_index :gp_person_events, :title_translations, using: :gin
    add_index :gp_person_events, :description_translations, using: :gin
  end
end
