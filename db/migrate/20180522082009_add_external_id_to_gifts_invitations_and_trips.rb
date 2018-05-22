# frozen_string_literal: true

class AddExternalIdToGiftsInvitationsAndTrips < ActiveRecord::Migration[5.2]
  def change
    add_column :gp_gifts, :external_id, :string
    add_column :gp_invitations, :external_id, :string
    add_column :gp_trips, :external_id, :string
  end
end
