# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class Plan < ApplicationRecord
    belongs_to :site
    belongs_to :plan_type
    has_many :categories
    has_many :nodes, through: :categories

    serialize :configuration_data

    translates :title, :description

    def levels
      categories.maximum("level")
    end
  end
end
