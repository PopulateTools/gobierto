# frozen_string_literal: true

module GobiertoCommon
  class Term < ApplicationRecord
    before_validation :calculate_level, :set_vocabulary
    include GobiertoCommon::Sluggable

    belongs_to :vocabulary

    has_many :terms
    belongs_to :parent_term, class_name: name, foreign_key: :term_id

    validates :vocabulary, :name_translations, :slug, :position, :level, presence: true
    validates :slug, uniqueness: { scope: :vocabulary_id }

    translates :name, :description

    def attributes_for_slug
      [vocabulary_name, name]
    end

    def vocabulary_name
      vocabulary.name
    end

    private

    def calculate_level
      if parent_term.present?
        self.level = parent_term.level + 1
      end
    end

    def set_vocabulary
      if parent_term.present?
        self.vocabulary_id = parent_term.vocabulary_id
      end
    end
  end
end
