# frozen_string_literal: true

class AddEncryptedMetaToPollAnswers < ActiveRecord::Migration[5.2]

  def change
    add_column :gpart_poll_answers, :encrypted_meta, :text

    add_index :gpart_poll_answers, [:question_id, :user_id_hmac, :answer_template_id], name: "unique_index_gpart_poll_answers_for_fixed_answer_questions", unique: true
    add_index :gpart_poll_answers, [:user_id_hmac, :answer_template_id], name: "unique_index_gpart_poll_answers_for_open_answer_questions", unique: true
    add_index :gpart_poll_answers, :user_id_hmac, name: "index_gpart_poll_answers_on_user_id_hmac"
  end

end
