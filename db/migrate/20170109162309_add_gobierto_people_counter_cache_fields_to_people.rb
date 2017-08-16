# frozen_string_literal: true

class AddGobiertoPeopleCounterCacheFieldsToPeople < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_people, :events_count, :integer, null: false, default: 0
    add_column :gp_people, :statements_count, :integer, null: false, default: 0
    add_column :gp_people, :posts_count, :integer, null: false, default: 0
  end
end
