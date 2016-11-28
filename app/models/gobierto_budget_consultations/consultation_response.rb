require_dependency "gobierto_budget_consultations"

module GobiertoBudgetConsultations
  class ConsultationResponse < ApplicationRecord
    belongs_to :consultation
    belongs_to :user

    serialize :consultation_items, Hash

    enum visibility_level: { draft: 0, active: 1 }
  end
end
