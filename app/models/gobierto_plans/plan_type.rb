# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class PlanType < ApplicationRecord
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Validatable

    belongs_to :site
    has_many :plans, class_name: "GobiertoPlans::Plan", dependent: :restrict_with_error

    translates :name

    validates :name, presence: true
    validates :slug, uniqueness: true

    scope :sort_by_updated_at, -> { order(updated_at: :desc) }

    def attributes_for_slug
      [name]
    end

    def recent_plan_date
      plans.published.pluck(:year).sort.reverse!.first
    end
  end
end
