# frozen_string_literal: true

class AddSlugToGobiertoPeoplePoliticalGroup < ActiveRecord::Migration[5.0]
  def up
    add_column :gp_political_groups, :slug, :string
    ::GobiertoPeople::PoliticalGroup.reset_column_information
    create_slug_for_existing_political_groups
    change_column :gp_political_groups, :slug, :string, null: false
    add_index :gp_political_groups, :slug, unique: true
  end

  def down
    remove_column :gp_political_groups, :slug
  end

  private

  def create_slug_for_existing_political_groups
    GobiertoPeople::PoliticalGroup.all.each do |political_group|
      political_group.send(:set_slug)
      political_group.save!
    end
  end
end
