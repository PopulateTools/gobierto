# frozen_string_literal: true

class RemoveInvitaionOrganizerConstraint < ActiveRecord::Migration[5.2]
  def change
    change_column :gp_invitations, :organizer, :string, null: true
  end
end
