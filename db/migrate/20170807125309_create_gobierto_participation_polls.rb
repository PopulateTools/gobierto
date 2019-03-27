# frozen_string_literal: true

class CreateGobiertoParticipationPolls < ActiveRecord::Migration[5.1]

  def change
    create_table :gpart_polls do |t|
      t.belongs_to :process, null: false
      t.jsonb :title_translations
      t.jsonb :description_translations
      t.date :starts_at, null: false
      t.date :ends_at, null: false
      t.integer :visibility_level, null: false, default: 0
      t.timestamps
    end
  end

end
