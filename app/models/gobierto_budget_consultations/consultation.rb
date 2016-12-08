require_dependency "gobierto_budget_consultations"

module GobiertoBudgetConsultations
  class Consultation < ApplicationRecord
    belongs_to :admin, class_name: "GobiertoAdmin::Admin"
    belongs_to :site

    has_many :consultation_items, dependent: :destroy
    has_many :consultation_responses, dependent: :destroy

    validates :title, :description, presence: true
    validates :opens_on, :closes_on, presence: true

    enum visibility_level: { draft: 0, active: 1 }

    scope :sorted, -> { order(created_at: :desc) }
    scope :active, -> { select(&:open?) }
    scope :past, -> { where("closes_on < ?", Date.current) }
    scope :upcoming, -> { where("opens_on > ?", Date.current) }

    def open?
      visibility_level == "active" && opening_range.include?(Date.current)
    end

    def calculate_budget_amount
      update_columns(budget_amount: consultation_items.sum(:budget_line_amount))
    end

    private

    def opening_range
      opens_on..closes_on
    end
  end
end
