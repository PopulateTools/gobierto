# frozen_string_literal: true

module GobiertoCommon
  class Vocabulary < ApplicationRecord
    include GobiertoCommon::Sluggable

    belongs_to :site
    has_many :terms, dependent: :destroy

    validates :site, :name, :slug, presence: true
    validates :slug, uniqueness: { scope: :site_id }

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
      terms.order(position: :asc).where(level: minimum_level).map do |term|
        term.ordered_self_and_descendants
      end.flatten
    end
  end
end
