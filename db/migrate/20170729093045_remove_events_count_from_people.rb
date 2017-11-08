# frozen_string_literal: true

class RemoveEventsCountFromPeople < ActiveRecord::Migration[5.1]
  def change
    remove_column :gp_people, :events_count
  end
end
