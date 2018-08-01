# frozen_string_literal: true

class AddSlugToGobiertoPeoplePoliticalGroup < ActiveRecord::Migration[5.0]
  def up
    add_column :gp_political_groups, :slug, :string
    change_column :gp_political_groups, :slug, :string, null: false
    add_index :gp_political_groups, :slug, unique: true
  end

  def down
    remove_column :gp_political_groups, :slug
  end
end
