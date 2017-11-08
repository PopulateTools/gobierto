# frozen_string_literal: true

class AddSlugToGobiertoPeoplePersonEvent < ActiveRecord::Migration[5.0]
  def up
    add_column :gp_person_events, :slug, :string
    change_column :gp_person_events, :slug, :string, null: false
    change_column :gp_person_events, :starts_at, :datetime, null: false
    change_column :gp_person_events, :ends_at, :datetime, null: false
    add_index :gp_person_events, :slug, unique: true
  end

  def down
    remove_column :gp_person_events, :slug
    change_column :gp_person_events, :starts_at, :datetime
    change_column :gp_person_events, :ends_at, :datetime
  end
end
