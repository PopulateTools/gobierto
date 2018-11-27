# frozen_string_literal: true

module GobiertoCommon
  class Term < ApplicationRecord
    before_validation :calculate_level, :set_vocabulary
    include GobiertoCommon::Sortable
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

    delegate :site, to: :vocabulary

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
