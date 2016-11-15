class AddInvitationTokenToAdmins < ActiveRecord::Migration[5.0]
  def change
    add_column :admins, :invitation_token, :string
    add_column :admins, :invitation_sent_at, :datetime

    add_index :admins, :invitation_token, unique: true
  end
end
