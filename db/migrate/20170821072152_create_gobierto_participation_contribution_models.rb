# frozen_string_literal: true

class CreateGobiertoParticipationContributionModels < ActiveRecord::Migration[5.1]
  def change
    create_table :gpart_contribution_containers do |t|
      t.jsonb :title_translations, null: false, default: ""
      t.jsonb :description_translations, null: false, default: ""
      t.date :starts
      t.date :ends
      t.integer :contribution_type, null: false, default: 0
      t.integer :visibility_level, null: false, default: 0
      t.references :process
      t.references :admin
      t.references :site

      t.timestamps
    end

    create_table :gpart_contributions do |t|
      t.string :title, null: false, default: ""
      t.text :description, null: false, default: ""
      t.references :contribution_container
      t.references :user
      t.references :site
      t.integer :votes_count, default: 0
      t.integer :flags_count, default: 0
      t.integer :comments_count, default: 0

      t.timestamps
    end

    add_index :gpart_contributions, :title
    add_index :gpart_contributions, :description

    create_table :gpart_comments do |t|
      t.text :body, null: false, default: ""
      t.references :commentable, polymorphic: true, index: true
      t.references :user
      t.references :site
      t.integer :votes_count, default: 0
      t.integer :flags_count, default: 0

      t.timestamps
    end

    create_table :gpart_flags do |t|
      t.references :flaggable, polymorphic: true, index: true
      t.references :user
      t.references :site

      t.timestamps
    end

    create_table :gpart_votes do |t|
      t.references :votable, polymorphic: true
      t.boolean :vote_flag
      t.string :vote_scope
      t.integer :vote_weight
      t.references :user
      t.references :site

      t.timestamps
    end

    add_index :gpart_votes, [:user_id, :vote_scope]
    add_index :gpart_votes, [:votable_id, :votable_type, :vote_scope]
  end
end
