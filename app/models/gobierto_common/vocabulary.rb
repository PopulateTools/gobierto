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
  end
end
