# frozen_string_literal: true

require_dependency "gobierto_citizens_charters"

module GobiertoCitizensCharters
  class Commitment < ApplicationRecord
    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Searchable

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title_en, :title_es, :title_ca, :searchable_description
      searchableAttributes %w(title_en title_es title_ca searchable_description)
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    belongs_to :charter, -> { with_archived }
    has_many :editions, dependent: :destroy

    enum visibility_level: { draft: 0, active: 1 }

    validates :slug, uniqueness: { scope: :charter_id }
    translates :title
    translates :description
    delegate :site_id, to: :charter

    after_restore :set_slug

    def parameterize
      { slug: slug }
    end

    def attributes_for_slug
      [title]
    end

    def to_s
      title
    end

    def belongs_to_archived?
      charter.archived?
    end

    def searchable_description
      searchable_translated_attribute(description_translations)
    end

    def resource_path
      url_helpers.gobierto_citizens_charters_charter_url(slug: charter.slug, host: charter.service.site.domain)
    end
  end
end
