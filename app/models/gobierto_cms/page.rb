# frozen_string_literal: true

require_dependency "gobierto_cms"

module GobiertoCms
  class Page < ApplicationRecord
    paginates_per 10

    attr_accessor :admin_id

    include User::Subscribable
    include GobiertoCommon::Searchable
    include GobiertoAttachments::Attachable
    include GobiertoCommon::ActsAsCollectionContainer
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Collectionable

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title_en, :title_es, :title_ca, :body_en, :body_es, :body_ca, :collection_id
      searchableAttributes %w(title_en title_es title_ca body_en body_es body_ca)
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    translates :title, :body

    belongs_to :site
    belongs_to :collection, class_name: "GobiertoCommon::Collection"
    has_many :collection_items, as: :item

    after_create :add_item_to_collection

    enum visibility_level: { draft: 0, active: 1 }

    validates :site, :title, :body, presence: true
    validates :slug, uniqueness: { scope: :site }

    scope :sorted, -> { order(id: :desc) }
    scope :sort_by_updated_at, ->(num) { order(updated_at: :desc).limit(num) }

    def main_image
      attachments.each do |attachment|
        return attachment.url if attachment.content_type.start_with?("image/")
      end
      nil
    end

    def process
      GobiertoCommon::CollectionItem.where(item_id: id, item_type: %W(GobiertoCms::News GobiertoCms::Page), container_type: "GobiertoParticipation::Process").first.container
    end

    def template
      collection.item_type.split('::').last.downcase
    end

    # TODO: split methods to fetch news or pages
    def self.pages_in_collections(site)
      ids = GobiertoCommon::CollectionItem.where(item_type: %W(GobiertoCms::News GobiertoCms::Page)).pluck(:item_id)
      where(id: ids, site: site)
    end

    def self.pages_in_collections_and_container_type(site, container_type)
      ids = GobiertoCommon::CollectionItem.where(item_type: %W(GobiertoCms::News GobiertoCms::Page), container_type: container_type).pluck(:item_id)
      where(id: ids, site: site)
    end

    def self.pages_in_collections_and_container(site, container)
      ids = GobiertoCommon::CollectionItem.where(item_type: %W(GobiertoCms::News GobiertoCms::Page), container_type: container_type, container_id: container.id).pluck(:item_id)
      where(id: ids, site: site)
    end

    def attributes_for_slug
      [title]
    end

    def to_url(options = {})
      if collection
        if collection.container_type == "GobiertoParticipation::Process"
          url_helpers.gobierto_participation_process_page_url({ id: slug, process_id: collection.container.slug, host: app_host }.merge(options))
        elsif collection.container_type == "GobiertoParticipation"
          url_helpers.gobierto_participation_page_url({ id: slug, host: app_host }.merge(options))
        else
          url_helpers.gobierto_cms_page_url({ id: slug }.merge(host: app_host).merge(options))
        end
      end
    end

    def add_item_to_collection
      if collection
        collection.append(self)
      end
    end
  end
end
