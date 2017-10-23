# frozen_string_literal: true

require_dependency 'gobierto_participation'

module GobiertoParticipation
  class PollAnswerTemplate < ApplicationRecord

    belongs_to :question, class_name: 'GobiertoParticipation::PollQuestion'

    validates :question, :text, :order, presence: true

    def times_chosen
      ::GobiertoParticipation::PollAnswer.where(answer_template: self).count
    end

  end
end
