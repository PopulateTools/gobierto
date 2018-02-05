# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class Category < ApplicationRecord
    include GobiertoCommon::Sluggable

    belongs_to :plan
    has_and_belongs_to_many :nodes, class_name: "GobiertoPlans::Node"
    belongs_to :parent_category, class_name: "GobiertoPlans::Category", foreign_key: :parent_id
    has_many :categories, foreign_key: :parent_id

    translates :name

    def attributes_for_slug
      [name]
    end

    def descendants(children_array = [])
      children = GobiertoPlans::Category.where(parent_id: id)
      children_array += children.all
      children.each do |child|
        child.descendants(children_array)
      end
      children_array
    end
  end
end
