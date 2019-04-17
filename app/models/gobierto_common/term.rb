# frozen_string_literal: true

module GobiertoCommon
  class Term < ApplicationRecord
    before_validation :calculate_level, :set_vocabulary
    include GobiertoCommon::Sortable
    include GobiertoCommon::ActsAsTree
    include User::Subscribable
    include GobiertoCommon::Sluggable
    after_save :update_children_levels
    before_destroy :free_children

    belongs_to :vocabulary

    has_many :terms, dependent: :nullify
    belongs_to :parent_term, class_name: name, foreign_key: :term_id

    validates :vocabulary, :name, :slug, :position, :level, presence: true
    validates :slug, uniqueness: { scope: :vocabulary_id }

    scope :sorted, -> { order(position: :asc, created_at: :desc) }

    translates :name, :description

    delegate :site, :maximum_level, to: :vocabulary

    parent_item_foreign_key :term_id

    def attributes_for_slug
      [vocabulary_name, name]
    end

    def vocabulary_name
      vocabulary&.name
    end

    def destroy
      return false if has_dependent_resources?

      super
    end

    def has_dependent_resources?
      enabled_classes_with_vocabularies.any? do |klass|
        klass.vocabularies.keys.any? do |association|
          klass.where(klass.reflections[association.to_s].foreign_key => id).exists?
        end
      end ||
        GobiertoPlans::CategoryTermDecorator.new(self).has_dependent_resources?
    end

    def last_descendants
      return [self] if level == maximum_level

      terms.map(&:last_descendants).flatten
    end

    # positions_from_params arg: hash of arrays
    # The element with id 0 defines the order of the parent nodes
    # Example:
    #   {
    #     0: [parent_id_1, parent_id_2],
    #     parent_id_1: [children_id_1, children_id_2],
    #     parent_id_2: [children_id_3, children_id_4]
    #   }
    def self.update_parents_and_positions(positions_from_params)
      positions_from_params.each do |parent_id, children_ids|
        if parent_id == "0"
          children_ids.each_with_index do |child_id, position|
            where(id: child_id).update_all({ position: position, term_id: nil, level: 0 })
          end
        else
          children_ids.each_with_index do |child_id, position|
            parent_level = find(parent_id).level
            where(id: child_id).update_all({ position: position, term_id: parent_id, level: parent_level + 1 })
          end
        end
      end
    end

    private

    def calculate_level
      self.level = parent_term.present? ? parent_term.level + 1 : 0
    end

    def update_children_levels
      terms.each do |child|
        child.valid? && child.save
      end
    end

    def free_children
      terms.each do |child|
        child.term_id = nil
        child.valid? && child.save
      end
    end

    def set_vocabulary
      if parent_term.present?
        self.vocabulary_id = parent_term.vocabulary_id
      end
    end

    def enabled_classes_with_vocabularies
      vocabulary.site.configuration.modules.map do |module_name|
        module_name.constantize.try(:classes_with_vocabularies)
      end.flatten.compact
    end
  end
end
