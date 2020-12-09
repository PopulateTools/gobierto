# frozen_string_literal: true

module GobiertoCitizensCharters
  class Commitment < ApplicationRecord
    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Searchable

    multisearchable(
      against: [:title_es, :title_en, :title_ca, :searchable_description],
      additional_attributes: lambda { |item|
        {
          site_id: item.site_id,
          title_translations: item.truncated_translations(:title),
          resource_path: item.resource_path,
          searchable_updated_at: item.updated_at
        }
      },
      if: :searchable?
    )

    attr_accessor :admin_id

    belongs_to :charter, -> { with_archived }
    has_many :editions, dependent: :destroy

    enum visibility_level: { draft: 0, active: 1 }

    validates :slug, uniqueness: { scope: :charter_id }
    translates :title
    translates :description
    delegate :site_id, to: :charter

    scope :sorted, -> { order(title_translations: :asc) }

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
