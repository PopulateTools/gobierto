# frozen_string_literal: true

class AddJsonbLocationToTrips < ActiveRecord::Migration[5.2]

  def change
    remove_column :gp_invitations, :location
    add_column :gp_invitations, :location, :jsonb
    add_index :gp_invitations, :location, using: :gin
  end

end
