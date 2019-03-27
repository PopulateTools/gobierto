# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class PollQuestion < ApplicationRecord

    belongs_to :poll
    has_many :answer_templates, -> { order(order: :asc) }, class_name: "GobiertoParticipation::PollAnswerTemplate", foreign_key: :question_id, dependent: :destroy, autosave: true
    has_many :answers, class_name: "GobiertoParticipation::PollAnswer", foreign_key: :question_id

    translates :title

    enum answer_types: { single_choice: 0, multiple_choice: 1, open: 2 }

    accepts_nested_attributes_for :answer_templates, allow_destroy: true

    validates :poll, :answer_type, presence: true
    validates(
      :title_translations,
      translated_attribute_presence: true,
      translated_attribute_length: { maximum: 140 }
    )
    validate :answer_templates_size

    validates_associated :answer_templates, message: I18n.t("activerecord.messages.gobierto_participation/poll.are_not_valid")

    def open_answer?
      answer_type == PollQuestion.answer_types[:open]
    end

    def fixed_answer?
      !open_answer?
    end

    def single_choice?
      answer_type == PollQuestion.answer_types[:single_choice]
    end

    def multiple_choice?
      answer_type == PollQuestion.answer_types[:multiple_choice]
    end

    private

    def answer_templates_size
      if answer_type && fixed_answer? && answer_templates.size < 2
        errors.add(:answer_templates, I18n.t("activerecord.messages.gobierto_participation/poll_question.not_enough_alternatives"))
      end
    end

  end
end
