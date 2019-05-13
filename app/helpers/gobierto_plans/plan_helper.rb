# frozen_string_literal: true

module GobiertoPlans
  module PlanHelper
    def level_name_pluralize(plan, level)
      elements_count = level <= @plan.levels ? plan.categories.where(level: level).count : plan.nodes.published.count

      "#{elements_count} #{plan.level_key(elements_count, level)}"
    end
  end
end
