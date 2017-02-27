class ChangeGobiertoBudgetConsultationsConsultationResponsesLinkToUser < ActiveRecord::Migration[5.0]
  def up
    remove_index :gbc_consultation_responses, name: "index_gbc_consultation_responses_on_user_id"
    remove_column :gbc_consultation_responses, :user_id

    add_column :gbc_consultation_responses, :document_number_digest, :string
    add_index :gbc_consultation_responses, [:consultation_id, :document_number_digest], unique: true, name: "index_gbc_consultation_responses_on_document_number_digest"
  end

  def down
    remove_index :gbc_consultation_responses, name: "index_gbc_consultation_responses_on_document_number_digest"
    remove_column :gbc_consultation_responses, :document_number_digest

    add_column :gbc_consultation_responses, :user_id, :integer
    add_index :gbc_consultation_responses, [:user_id], name: "index_gbc_consultation_responses_on_user_id", unique: true
  end
end
