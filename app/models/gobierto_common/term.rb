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
    before_validation :clear_parent_if_itself

    belongs_to :vocabulary

    has_many :terms, dependent: :nullify
    belongs_to :parent_term, class_name: name, foreign_key: :term_id, optional: true

    validates :vocabulary, :slug, :position, :level, presence: true
    validates :name_translations, translated_attribute_presence: true

    validates :slug, uniqueness: { scope: :vocabulary_id }

    scope :sorted, -> { order(position: :asc, created_at: :desc) }
    scope :with_name, lambda { |name|
      where(%(terms.name_translations ->> 'en' ILIKE :name OR
      terms.name_translations ->> 'es' ILIKE :name OR
      terms.name_translations ->> 'ca' ILIKE :name), name: name.to_s)
    }

    translates :name, :description

    delegate :site, :maximum_level, to: :vocabulary

    parent_item_foreign_key :term_id

    def attributes_for_slug
      [name]
    end

    def vocabulary_name
      vocabulary&.name
    end

    def parent_id
      parent_external_id.presence || term_id
    end

    def parent_external_id
      parent_term&.external_id
    end

    def destroy
      dependent_resources_decorator = TermDependentResourcesDecorator.new(self)
      if dependent_resources_decorator.has_dependent_resources?
        errors.add(:base, :has_dependent_resources_html, dependencies_list: dependent_resources_decorator.dependencies_list)
        return false
      end

      super
    end

    def last_descendants
      return [self] if level == maximum_level

      terms.map(&:last_descendants).flatten
    end

    def ordered_self_and_descendants
      [self, self_and_descendents.reorder(:level).sorted.where(term_id: id).map(&:ordered_self_and_descendants)].flatten
    end

    def ordered_tree
      { self => self_and_descendents.reorder(:level).sorted.where(term_id: id).inject({}) { |subtree, el| subtree.merge(el.ordered_tree) } }
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

    def clear_parent_if_itself
      if parent_term == self
        self.term_id = nil
        errors.add(:term_id)
      end
    end
  end
end
