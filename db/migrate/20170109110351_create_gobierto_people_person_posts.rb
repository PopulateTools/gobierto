# frozen_string_literal: true

class CreateGobiertoPeoplePersonPosts < ActiveRecord::Migration[5.0]
  def change
    create_table :gp_person_posts do |t|
      t.string :title, null: false, default: ''
      t.text :body
      t.string :tags, array: true
      t.integer :visibility_level, null: false, default: 0
      t.references :person

      t.timestamps
    end
    add_index :gp_person_posts, :tags, using: :gin
  end
end
