# frozen_string_literal: true

class CreateGobiertoParticipationContributorContainer < ActiveRecord::Migration[5.1]
  def change
    create_table :gpart_contributor_containers do |t|
      t.jsonb :title_translations, null: false, default: ""
      t.jsonb :description_translations, null: false, default: ""
      t.date :starts
      t.date :ends
      t.integer :contribution_type, null: false, default: 0
      t.integer :visibility_level, null: false, default: 0
      t.references :site

      t.timestamps
    end
  end
end
