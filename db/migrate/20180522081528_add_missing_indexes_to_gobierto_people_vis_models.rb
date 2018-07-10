# frozen_string_literal: true

class AddMissingIndexesToGobiertoPeopleVisModels < ActiveRecord::Migration[5.2]

  def change
    add_index :gc_events, :meta, using: :gin
    add_index :gp_gifts, :meta, using: :gin
    add_index :gp_interest_groups, :meta, using: :gin
    add_index :gp_invitations, :meta, using: :gin
    add_index :gp_trips, :destinations_meta, using: :gin
    add_index :gp_trips, :meta, using: :gin
  end

end
