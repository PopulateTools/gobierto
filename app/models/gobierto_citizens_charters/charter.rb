# frozen_string_literal: true

require_dependency "gobierto_citizens_charters"

module GobiertoCitizensCharters
  class Charter < ApplicationRecord
    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Searchable

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title_en, :title_es, :title_ca, :searchable_custom_fields
      searchableAttributes %w(title_en title_es title_ca searchable_custom_fields)
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    attr_accessor :admin_id

    belongs_to :service, -> { with_archived }
    has_many :commitments, dependent: :destroy
    has_many :editions, through: :commitments, class_name: "GobiertoCitizensCharters::Edition"

    enum visibility_level: { draft: 0, active: 1 }

    validates :slug, uniqueness: { scope: :service_id }
    translates :title
    delegate :category, :site_id, to: :service

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
      service.archived?
    end

    def searchable_custom_fields
      searchable_values = GobiertoCommon::CustomFieldRecord.searchable.for_item(self).map do |record|
        if record.custom_field.has_localized_value?
          searchable_translated_attribute(record.searchable_value)
        else
          searchable_attribute(record.searchable_value)
        end
      end
      searchable_values.sort_by { |value| -value.length }.join(" ")[0..9300]
    end

    def resource_path
      url_helpers.gobierto_citizens_charters_charter_url(slug: slug, host: service.site.domain)
    end
  end
end
