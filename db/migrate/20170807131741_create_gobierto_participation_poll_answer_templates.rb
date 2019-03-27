# frozen_string_literal: true

class CreateGobiertoParticipationPollAnswerTemplates < ActiveRecord::Migration[5.1]

  def change
    create_table :gpart_poll_answer_templates do |t|
      t.belongs_to :question, null: false
      t.string :text, null: false
      t.integer :order, null: false, default: 0
    end
  end

end
