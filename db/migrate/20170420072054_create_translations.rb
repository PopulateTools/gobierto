# frozen_string_literal: true

class CreateTranslations < ActiveRecord::Migration[5.0]
  def change
    create_table :translations do |t|
      t.string :locale
      t.string :key
      t.text   :value
      t.text   :interpolations
      t.boolean :is_proc, default: false

      t.timestamps
    end

    add_index :translations, :locale
    add_index :translations, :key
  end
end
