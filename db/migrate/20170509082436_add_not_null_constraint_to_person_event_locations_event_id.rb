# frozen_string_literal: true

class AddNotNullConstraintToPersonEventLocationsEventId < ActiveRecord::Migration[5.0]
  def up
    change_column :gp_person_event_locations, :person_event_id, :integer, null: false
  end

  def down
    change_column :gp_person_event_locations, :person_event_id, :integer
  end
end
