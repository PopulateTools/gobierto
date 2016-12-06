class AddSharingTokenToConsultationResponses < ActiveRecord::Migration[5.0]
  def change
    add_column :gbc_consultation_responses, :sharing_token, :string
    add_index :gbc_consultation_responses, :sharing_token, unique: true
  end
end
