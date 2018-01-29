# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class Category < ApplicationRecord
    belongs_to :plan
    has_and_belongs_to_many :nodes, dependent: :destroy, class_name: "GobiertoPlans::Node"

    translates :name
  end
end
