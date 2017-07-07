class CreateGobiertoParticipationIssues < ActiveRecord::Migration[5.1]
  def change
    create_table :gpart_issues do |t|
      t.references :site
      t.jsonb :name_translations
      t.jsonb :slug_translations

      t.timestamps
    end

    add_index :gpart_issues, :name_translations, using: :gin
    add_index :gpart_issues, :slug_translations, using: :gin
  end
end
