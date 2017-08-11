# frozen_string_literal: true

class AddPersonIdNotNullConstraintToGobiertoPeoplePersonEvent < ActiveRecord::Migration[5.0]
  def change
    change_column :gp_person_events, :person_id, :integer, null: false
  end
end
