# frozen_string_literal: true

module GobiertoPlans
  class CategoryTermDecorator < BaseDecorator
    def initialize(term)
      @object = term
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
      @progress ||= begin
                      depending_categories = [object]
                      max_level = plan.categories.maximum(:level)
                      (max_level - object.level).times do
                        depending_categories += ::GobiertoCommon::Term.where(term_id: depending_categories.pluck(:id))
                      end

                      depending_nodes = plan.nodes.where(gplan_categories_nodes: { category_id: depending_categories.pluck(:id) })
                      depending_nodes.blank? ? nil : depending_nodes.average(:progress).to_f
                    end
    end

    def parent_id
      @parent_id ||= object.term_id
    end

    def nodes
      plan.nodes.where(gplan_categories_nodes: { category_id: object.id })
    end

    protected

    def vocabulary
      @vocabulary ||= object.vocabulary
    end
  end
end
