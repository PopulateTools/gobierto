# frozen_string_literal: true

require_dependency "gobierto_cms"

module GobiertoCms
  class Page < ApplicationRecord
    acts_as_paranoid column: :archived_at

    paginates_per 10

    attr_accessor :admin_id

    include ActsAsParanoidAliases
    include User::Subscribable
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
    belongs_to :collection, class_name: "GobiertoCommon::Collection"
    has_many :collection_items, as: :item
    has_many :process_stage_pages, class_name: "GobiertoParticipation::ProcessStagePage"

    after_create :add_item_to_collection
    after_restore :set_slug

    enum visibility_level: { draft: 0, active: 1 }

    validates :site, :title, :body, presence: true
    validates :slug, uniqueness: { scope: :site }

    scope :inverse_sorted, -> { order(id: :asc) }
    scope :sorted, -> { order(id: :desc) }
    scope :sort_by_updated_at, -> { order(updated_at: :desc) }

    def main_image
      attachments.each do |attachment|
        return attachment.url if attachment.content_type.start_with?("image/")
      end
      nil
    end

    def section
      if GobiertoCms::SectionItem.where(item: self).first
        GobiertoCms::SectionItem.where(item: self).first.section
      end
    end

    def template
      collection.item_type.split('::').last.downcase
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

    def resource_path
      to_url
    end

    def belongs_to_collection_of_news?
      collection && collection.item_type == 'GobiertoCms::News'
    end

    def belongs_to_collection_of_pages?
      collection && collection.item_type == 'GobiertoCms::Page'
    end

    def to_path(options = {})
      if collection
        if collection.container_type == "GobiertoParticipation::Process"
          url_helpers.gobierto_participation_process_page_path({ id: slug, process_id: collection.container.slug }.merge(options))
        elsif collection.container_type == "GobiertoParticipation"
          if  belongs_to_collection_of_news?
            url_helpers.gobierto_participation_news_path({ id: slug }.merge(options))
          elsif belongs_to_collection_of_pages?
            url_helpers.gobierto_participation_page_path({ id: slug }.merge(options))
          end
        elsif section.present? || options[:section]
          options.delete(:section)
          url_helpers.gobierto_cms_section_item_path({ id: slug, slug_section: section.slug }.merge(options))
        else
          url_helpers.gobierto_cms_page_path({ id: slug }.merge(options))
        end
      end
    end

    def to_url(options = {})
      host = site.domain
      if collection
        if collection.container_type == "GobiertoParticipation::Process"
          url_helpers.gobierto_participation_process_page_url({ id: slug, process_id: collection.container.slug, host: host }.merge(options))
        elsif collection.container_type == "GobiertoParticipation"
          if  belongs_to_collection_of_news?
            url_helpers.gobierto_participation_news_url({ id: slug, host: host }.merge(options))
          elsif belongs_to_collection_of_pages?
            url_helpers.gobierto_participation_page_url({ id: slug, host: host }.merge(options))
          end
        elsif section.present? || options[:section]
          options.delete(:section)
          url_helpers.gobierto_cms_section_item_url({ id: slug, slug_section: section.slug, host: host }.merge(options))
        else
          url_helpers.gobierto_cms_page_url({ id: slug }.merge(host: host).merge(options))
        end
      end
    end

    def add_item_to_collection
      if collection
        collection.append(self)
      end
    end

    def searchable_body
      searchable_translated_attribute(body_translations)
    end
  end
end
