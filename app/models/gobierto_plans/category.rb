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
        children_array = child.descendants(children_array)
      end
      children_array
    end

    def uid(uid = "")
      uid = if parent_id && parent_id.positive?
              parent = GobiertoPlans::Category.find(parent_id)
              index = GobiertoPlans::Category.where(parent_id: parent).index(self)
              uid = "." + index.to_s + uid
              parent.uid(uid)
            else
              roots = GobiertoPlans::Category.where(parent_id: nil)
              index = roots.index(self)
              index.to_s + uid
            end

      uid
    end

    def children_progress
      descendants_array = descendants
      descendants = GobiertoPlans::Category.where(id: descendants_array.map(&:id))
      max_level = descendants.maximum(:level)

      descendants_leaves = descendants.where(level: max_level)
      if descendants_leaves.any?
        descendants_leaves_id = descendants_leaves.pluck(:id)
        node_ids = GobiertoPlans::CategoriesNode.where(category_id: descendants_leaves_id).pluck(:node_id)
        nodes = GobiertoPlans::Node.where(id: node_ids)
        progress_sum = nodes.sum(:progress)/node_ids.length
      else
        0
      end
    end
  end
end
