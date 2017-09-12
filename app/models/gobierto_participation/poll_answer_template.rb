require_dependency 'gobierto_participation'

module GobiertoParticipation
  class PollAnswerTemplate < ApplicationRecord

    belongs_to :question, class_name: 'GobiertoParticipation::PollQuestion'

    validates :question, :text, :order, presence: true

  end
end
