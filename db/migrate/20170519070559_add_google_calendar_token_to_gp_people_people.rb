# frozen_string_literal: true

class AddGoogleCalendarTokenToGpPeoplePeople < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_people, :google_calendar_token, :string
    add_index :gp_people, :google_calendar_token, unique: true
  end
end
