# frozen_string_literal: true

class AddNotNullConstraintToPersonEventAttendeesEventId < ActiveRecord::Migration[5.0]
  def up
    change_column :gp_person_event_attendees, :person_event_id, :integer, null: false
  end

  def down
    change_column :gp_person_event_attendees, :person_event_id, :integer
  end
end
