# frozen_string_literal: true

module GobiertoCommon
  class VocabularyDecorator < BaseDecorator
    def initialize(vocabulary)
      @object = vocabulary
    end

    def terms_for_select
      flatten_tree(@object.terms).map do |term|
        ["#{"--" * term.level} #{term.name}".strip, term.id]
      end
    end

    def flatten_tree(relation, level = 0)
      level_relation = relation.where(level: level).order(position: :asc)
      return [] if level_relation.blank?

      level_relation.where(level: level).map do |node|
        [node, flatten_tree(node.terms, level + 1)].flatten
      end.flatten
    end
  end
end
