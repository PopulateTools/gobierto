# frozen_string_literal: true

require_dependency "gobierto_cms"

module GobiertoCms
  class Page < ApplicationRecord
    acts_as_paranoid column: :archived_at

    paginates_per 10

    attr_accessor :admin_id

    include ActsAsParanoidAliases
    include User::Subscribable
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Searchable
    include GobiertoAttachments::Attachable
    include GobiertoCommon::ActsAsCollectionContainer
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Collectionable
    include GobiertoCommon::Sectionable

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title_en, :title_es, :title_ca, :searchable_body, :collection_id
      searchableAttributes %w(title_en title_es title_ca searchable_body)
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    translates :title, :body, :body_source

    belongs_to :site
    has_many :collection_items, as: :item
    has_many :process_stage_pages, class_name: "GobiertoParticipation::ProcessStagePage"

    after_create :add_item_to_collection
    after_restore :set_slug

    enum visibility_level: { draft: 0, active: 1 }

    validates :site, :title, :body, :published_on, presence: true
    validates :slug, uniqueness: { scope: :site_id }

    scope :inverse_sorted, -> { order(id: :asc) }
    scope :sorted, -> { order(id: :desc) }
    scope :sort_by_published_on, -> { order(published_on: :desc) }
    scope :sort_by_updated_at, -> { order(updated_at: :desc) }
    scope :news_in_collections, ->(site) {
      joins(Arel.sql("join collection_items on collection_items.item_id = #{ self.table_name }.id"))
        .where("collection_items.item_type = ?", "GobiertoCms::News")
        .where(site: site)
        .distinct
    }
    scope :news_in_collections_and_container_type, ->(site, container_type) {
      news_in_collections(site)
        .where("collection_items.container_type = ?", container_type)
    }
    scope :news_in_collections_and_container, ->(site, container) {
      news_in_collections(site)
        .where("collection_items.container_type = ?", container.class.name)
        .where("collection_items.container_id = ?", container.id)
    }

    def section
      GobiertoCms::SectionItem.find_by(item: self).try(:section)
    end

    def attributes_for_slug
      [title]
    end

    def add_item_to_collection
      collection&.append(self)
    end

    def public?
      active? && public_parent?
    end

    def destroyable?
      process_stage_pages.empty?
    end

    def parameterize
      params = { id: slug }
      page? && section ? params.merge(slug_section: section.slug) : params
    end

    alias resource_path to_url

    private

    def searchable_body
      searchable_translated_attribute(body_translations)
    end

    def singular_route_key
      if page? && section
        :gobierto_cms_section_item
      elsif news?
        :gobierto_cms_news
      else
        super
      end
    end

    def public_parent?
      container.try(:reload).try(:public?) != false
    end

    def page?
      collection&.item_type == "GobiertoCms::Page"
    end

    def news?
      collection&.item_type == "GobiertoCms::News"
    end

  end
end
