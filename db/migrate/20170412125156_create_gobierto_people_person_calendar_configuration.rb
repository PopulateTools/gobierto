# frozen_string_literal: true

class CreateGobiertoPeoplePersonCalendarConfiguration < ActiveRecord::Migration[5.0]
  def change
    create_table :gp_person_calendar_configurations do |t|
      t.integer :person_id, null: false
      t.jsonb :data, null: false, default: '{}'
    end
  end
end
