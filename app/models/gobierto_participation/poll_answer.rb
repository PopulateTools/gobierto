# frozen_string_literal: true

require_dependency 'gobierto_participation'

module GobiertoParticipation
  class PollAnswer < ApplicationRecord

    class QuestionAlreadyAnswered < StandardError; end

    belongs_to :poll
    belongs_to :question, class_name: 'GobiertoParticipation::PollQuestion'
    belongs_to :answer_template, class_name: 'GobiertoParticipation::PollAnswerTemplate'

    scope :open_answers,  -> { where(answer_template: nil) }
    scope :fixed_answers, -> { where.not(answer_template: nil) }
    scope :by_user, ->(user) { where(user_id_hmac: user.id_hmac) }

    validates_uniqueness_of :user_id_hmac, scope: [:question_id], if: :open_answer?
    validates_uniqueness_of :user_id_hmac, scope: [:question_id, :answer_template_id], if: :fixed_answer?

    validates_presence_of :text, if: :open_answer?
    validates_absence_of  :text,  if: :fixed_answer?

    validates_presence_of :answer_template, if: :fixed_answer?
    validates_absence_of  :answer_template, if: :open_answer?

    def open_answer?
      question.open?
    end

    def fixed_answer?
      question.fixed_answer?
    end

  end
end
