# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class PlanType < ApplicationRecord
    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases
    include GobiertoCommon::Sluggable

    has_many :plans, class_name: "GobiertoPlans::Plan", dependent: :restrict_with_error

    validates :name, presence: true
    validates :slug, uniqueness: true

    def attributes_for_slug
      [name]
    end
  end
end
