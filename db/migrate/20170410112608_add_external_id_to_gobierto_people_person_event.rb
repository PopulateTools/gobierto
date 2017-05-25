# frozen_string_literal: true

class AddExternalIdToGobiertoPeoplePersonEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_person_events, :external_id, :string
    add_index :gp_person_events, %i[person_id external_id], unique: true
  end
end
