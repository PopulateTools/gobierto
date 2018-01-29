# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class Plan < ApplicationRecord
    belongs_to :site
  end
end
