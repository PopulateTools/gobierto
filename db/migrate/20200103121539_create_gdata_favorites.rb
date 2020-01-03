# frozen_string_literal: true

class CreateGdataFavorites < ActiveRecord::Migration[5.2]
  def change
    create_table :gdata_favorites do |t|
      t.references :user
      t.references :favorited, polymorphic: true

      t.timestamps
    end
  end
end
