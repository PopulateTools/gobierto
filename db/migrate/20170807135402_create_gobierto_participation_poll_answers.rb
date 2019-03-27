# frozen_string_literal: true

class CreateGobiertoParticipationPollAnswers < ActiveRecord::Migration[5.1]

  def change
    create_table :gpart_poll_answers do |t|
      t.belongs_to :poll, null: false
      t.belongs_to :question, null: false
      t.integer :answer_template_id
      t.text :text
      t.belongs_to :user, null: false
      t.datetime :created_at
    end

    add_index :gpart_poll_answers, [:question_id, :user_id, :answer_template_id], name: "unique_index_gpart_poll_answers_for_fixed_answer_questions", unique: true
    add_index :gpart_poll_answers, [:user_id, :answer_template_id], name: "unique_index_gpart_poll_answers_for_open_answer_questions", unique: true
  end

end
