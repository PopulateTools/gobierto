class CreateGobiertoParticipationProcessStages < ActiveRecord::Migration[5.1]
  def change
    create_table :gpart_process_stages do |t|
      t.references :process
      t.jsonb :title_translations
      t.jsonb :slug_translations
      t.date :starts
      t.date :ends
      t.timestamps
    end
    add_index :gpart_process_stages, :title_translations, using: :gin
    add_index :gpart_process_stages, :slug_translations, using: :gin
  end
end
