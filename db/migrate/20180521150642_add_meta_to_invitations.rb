# frozen_string_literal: true

class AddMetaToInvitations < ActiveRecord::Migration[5.2]
  def change
    add_column :gp_invitations, :meta, :jsonb
  end
end
