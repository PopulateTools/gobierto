# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class Category < ApplicationRecord
    belongs_to :plan
    has_and_belongs_to_many :nodes, dependent: :destroy, class_name: "GobiertoPlans::Node"

    belongs_to :parent_category, class_name: "GobiertoPlans::Category", foreign_key: :parent_id
    has_many :categories, foreign_key: :parent_id

    translates :name
  end
end
