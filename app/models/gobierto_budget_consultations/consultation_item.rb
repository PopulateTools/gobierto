require_dependency "gobierto_budget_consultations"

module GobiertoBudgetConsultations
  class ConsultationItem < ApplicationRecord
    AVAILABLE_RESPONSES = {
      0 => "reduce",
      1 => "keep",
      2 => "increase"
    }.freeze

    belongs_to :consultation

    validates :title, presence: true

    scope :sorted, -> { order(position: :asc, created_at: :desc) }

    def available_responses
      AVAILABLE_RESPONSES
    end
  end
end
