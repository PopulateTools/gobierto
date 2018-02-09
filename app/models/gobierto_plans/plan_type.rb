# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class PlanType < ApplicationRecord
    has_many :plans
  end
end
