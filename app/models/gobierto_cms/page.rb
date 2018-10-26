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
    validates :slug, uniqueness: { scope: :site }

    scope :inverse_sorted, -> { order(id: :asc) }
    scope :sorted, -> { order(id: :desc) }
    scope :sort_by_published_on, -> { order(published_on: :desc) }
    scope :sort_by_updated_at, -> { order(updated_at: :desc) }

    def section
      GobiertoCms::SectionItem.find_by(item: self).try(:section)
    end

    # returns pages belonging to site pages collection
    def self.pages_in_collections(site)
      pages_ids = GobiertoCommon::CollectionItem.pages.pluck(:item_id)
      where(id: pages_ids, site: site)
    end

    # returns news belonging to site news collection
    def self.news_in_collections(site)
      news_ids = GobiertoCommon::CollectionItem.news.pluck(:item_id)
      where(id: news_ids, site: site)
    end

    # returns pages belonging to module pages collection
    # sample call: *.pages_in_collections_and_container_type(current_site, 'GobiertoParticipation')
    def self.pages_in_collections_and_container_type(site, container_type)
      ids = GobiertoCommon::CollectionItem.pages.by_container_type(container_type).pluck(:item_id)
      where(id: ids, site: site)
    end

    # returns news belonging to module news collection
    # sample call: *.news_in_collections_and_container_type(current_site, 'GobiertoParticipation')
    def self.news_in_collections_and_container_type(site, container_type)
      ids = GobiertoCommon::CollectionItem.news.by_container_type(container_type).pluck(:item_id)
      where(id: ids, site: site)
    end

    ## Methods to find items belonging to process, issue, etc.
    # sample call: *.pages_in_collections_and_container(current_site, @issue)
    def self.pages_in_collections_and_container(site, container)
      ids = GobiertoCommon::CollectionItem.pages_and_news.by_container(container).pluck(:item_id)
      where(id: ids, site: site)
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
