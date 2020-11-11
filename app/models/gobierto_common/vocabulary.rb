# frozen_string_literal: true

module GobiertoCommon
  class Vocabulary < ApplicationRecord
    include GobiertoCommon::Sluggable

    belongs_to :site
    has_many :terms, dependent: :destroy

    validates :site, :name, :slug, presence: true
    validates :slug, uniqueness: { scope: :site_id }

    after_touch :touch_associated_custom_field_items

    translates :name

    def attributes_for_slug
      [name]
    end

    def maximum_level
      terms.maximum(:level)
    end

    def minimum_level
      terms.minimum(:level)
    end

    def ordered_flatten_terms_tree
      terms.order(position: :asc).where(level: minimum_level).map(&:ordered_self_and_descendants).flatten
    end

    def update_terms_positions(sort_params)
      sort_params.values.each do |term_attributes|
        term_attributes[:class].constantize.where(id: term_attributes[:id]).update_all(position: term_attributes[:position])
      end
    end

    def copy_terms_from(origin, destination = nil)
      parent_terms = origin.is_a?(Vocabulary) ? origin.terms.where(term_id: nil) : origin.terms
      destination ||= self

      parent_terms.each do |subterm|
        copied_term = destination.terms.create(subterm.attributes.slice("name_translations", "description_translations", "slug", "position", "level"))
        copy_terms_from(subterm, copied_term)
      end
    end

    private

    def touch_associated_custom_field_items
      CustomFieldRecord.where(custom_field: CustomField.vocabulary_options.for_vocabulary(self)).each { |record| record&.item&.touch }
    end
  end
end
