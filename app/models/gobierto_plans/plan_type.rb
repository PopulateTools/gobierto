# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class PlanType < ApplicationRecord
    include GobiertoCommon::Sluggable

    belongs_to :site
    has_many :plans, class_name: "GobiertoPlans::Plan", dependent: :restrict_with_error

    translates :name

    validates :name, presence: true
    validates :slug, uniqueness: { scope: :site_id }

    scope :sort_by_updated_at, -> { order(updated_at: :desc) }

    def attributes_for_slug
      [name]
    end

    def self.site_plan_types_with_years(site)
      site.plan_types.joins(:plans).where("visibility_level = ?", GobiertoPlans::Plan.visibility_levels[:published]).
        select("max(year) as max_year, gplan_plan_types.*").
        group("gplan_plan_types.id")
    end
  end
end
