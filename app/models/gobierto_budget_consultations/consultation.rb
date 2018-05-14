require_dependency "gobierto_budget_consultations"

module GobiertoBudgetConsultations
  class Consultation < ApplicationRecord
    include User::Subscribable

    belongs_to :admin, class_name: "GobiertoAdmin::Admin"
    belongs_to :site

    has_many :consultation_items, dependent: :destroy
    has_many :consultation_responses, dependent: :destroy

    validates :title, :description, :opens_on, :closes_on, presence: true

    enum visibility_level: { draft: 0, active: 1 }

    scope :sorted,            -> { order(created_at: :desc) }
    scope :active_visibility, -> { where(visibility_level: visibility_levels[:active]) }
    scope :active,            -> { select(&:open?) }
    scope :not_draft,         -> { where.not(visibility_level: visibility_levels[:draft]) }
    scope :past,              -> { not_draft.where("closes_on < ?", Date.current) }
    scope :upcoming,          -> { not_draft.where("opens_on > ?", Date.current) }
    scope :opening_today,     -> { active_visibility.where(opens_on: Date.current) }
    scope :closing_today,     -> { active_visibility.where(closes_on: Date.current) }
    scope :about_to_close,    -> { active_visibility.where(closes_on: 2.days.from_now.to_date) }

    def open?
      active? && opening_range.include?(Date.current)
    end

    def past?
      closes_on < Date.current
    end

    def upcoming?
      opens_on > Date.current
    end

    def not_draft?
      self.class.visibility_levels[visibility_level] == self.class.visibility_levels[:active]
    end

    def calculate_budget_amount
      update_columns(budget_amount: consultation_items.sum(:budget_line_amount))
    end

    def already_responded?(user)
      if user && user.verified_in_site?(site)
        consultation_responses.exists?(document_number_digest: user.site_verification(site).document_number_digest)
      else
        false
      end
    end

    def projected_responses
      @projected_responses ||= begin
        if open? && consultation_responses.any? && days_open > 0
          ((consultation_responses.count / days_open.to_f) * days_left).ceil + consultation_responses.count
        else
          nil
        end
      end
    end

    def days_left
      (closes_on - Date.current ).to_i
    end

    private

    def opening_range
      opens_on..closes_on
    end

    def days_open
      (Date.current - opens_on).to_i
    end
  end
end
