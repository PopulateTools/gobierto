# frozen_string_literal: true

class CreateVocabularies < ActiveRecord::Migration[5.2]
  def change
    create_table :vocabularies do |t|
      t.references :site
      t.string :name

      t.timestamps
    end
  end
end
