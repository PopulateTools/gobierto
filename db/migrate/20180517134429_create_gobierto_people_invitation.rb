# frozen_string_literal: true

class CreateGobiertoPeopleInvitation < ActiveRecord::Migration[5.2]

  def change
    create_table :gp_invitations do |t|
      t.references :person, null: false
      t.string :organizer, null: false
      t.string :title, null: false
      t.string :location
      t.date :start_date, null: false
      t.date :end_date, null: false
    end
  end

end
