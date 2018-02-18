class AddMissingSourceTranslations < ActiveRecord::Migration[5.1]
  def change
    add_column :gp_people, :bio_source_translations, :jsonb
    add_index :gp_people, :bio_source_translations, using: :gin
    add_column :gc_events, :description_source_translations, :jsonb
    add_index :gc_events, :description_source_translations, using: :gin
    add_column :gp_person_posts, :body_source, :text
  end
end
