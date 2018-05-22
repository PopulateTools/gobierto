# frozen_string_literal: true

class AddDepartmentToGiftsInvitationsAndTrips < ActiveRecord::Migration[5.2]
  def change
    add_reference :gp_gifts, :department, index: true
    add_reference :gp_invitations, :department, index: true
    add_reference :gp_trips, :department, index: true
  end
end
