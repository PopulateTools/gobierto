class AddExternalIdToGobiertoPeoplePersonEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_person_events, :external_id, :string
  end
end
