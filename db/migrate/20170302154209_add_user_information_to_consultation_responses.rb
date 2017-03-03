class AddUserInformationToConsultationResponses < ActiveRecord::Migration[5.0]
  def change
    add_column :gbc_consultation_responses, :user_information, :jsonb
    add_index :gbc_consultation_responses, :user_information, using: :gin
  end
end
