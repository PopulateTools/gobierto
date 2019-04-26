# frozen_string_literal: true

module GobiertoPlans
  class CategoryTermDecorator < BaseTermDecorator
    include ActionView::Helpers::NumberHelper

    def initialize(term, options = {})
      @object = term
      @plan = options.delete(:plan)
    end

    def categories
      terms
    end

    def site
      @site ||= vocabulary.site
    end

    def plan
      @plan ||= site.plans.find_by_vocabulary_id(vocabulary.id)
    end

    def uid
      @uid ||= begin
                 category = object
                 indices = []
                 while category.present?
                   same_level_ids = plan.categories.where(level: category.level, term_id: category.term_id).sorted.pluck(:id)
                   indices.unshift(same_level_ids.index(category.id))
                   category = category.parent_term
                 end
                 indices.join(".")
               end
    end

    def progress
      return if nodes_count.zero?

      @progress ||= descending_nodes.average(:progress).to_f
    end

    def progress_percentage
      return if nodes_count.zero?

      @progress_percentage ||= number_to_percentage(progress, precision: 1, strip_insignificant_zeros: true)
    end

    def nodes_count
      @nodes_count ||= descending_nodes.count
    end

    def parent_id
      @parent_id ||= object.term_id
    end

    def nodes
      plan.nodes.where(gplan_categories_nodes: { category_id: object.id })
    end

    def has_dependent_resources?
      plan.present? && progress.present?
    end

    def self.decorated_values?
      true
    end

    def self.decorated_header_template
      "header"
    end

    def self.decorated_values_template
      "values"
    end

    def self.decorated_resources_template
      "resources"
    end

    def decorated_values
      { items: nodes_count, progress: progress_percentage }
    end

    def decorated_resources
      return if nodes_count.zero?

      { projects: nodes, plan: plan }
    end

    protected

    def descending_nodes
      @descending_nodes ||= plan.nodes.where("gplan_categories_nodes.category_id IN (#{self.class.tree_sql_for(self)})")
    end

    def vocabulary
      @vocabulary ||= object.vocabulary
    end
  end
end
