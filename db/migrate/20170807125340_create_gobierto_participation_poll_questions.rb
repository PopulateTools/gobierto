# frozen_string_literal: true

class CreateGobiertoParticipationPollQuestions < ActiveRecord::Migration[5.1]

  def change
    create_table :gpart_poll_questions do |t|
      t.belongs_to :poll, null: false
      t.jsonb :title_translations
      t.integer :answer_type, null: false, default: 0
      t.integer :order, null: false, default: 0
    end
  end

end
