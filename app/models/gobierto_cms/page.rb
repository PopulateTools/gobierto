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
    include GobiertoCommon::Sectionable
    include ActionView::Helpers::SanitizeHelper

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

    after_create :add_item_to_collection

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
      ids = GobiertoCommon::CollectionItem.where(item_type: %W(GobiertoCms::News GobiertoCms::Page), container_type: container.class.name, container_id: container.id).pluck(:item_id)
      where(id: ids, site: site)
    end

    def attributes_for_slug
      [title]
    end

    def resource_path
      to_url
    end

    def to_path(options = {})
      if collection
        if collection.container_type == "GobiertoParticipation::Process"
          url_helpers.gobierto_participation_process_page_path({ id: slug, process_id: collection.container.slug }.merge(options))
        elsif collection.container_type == "GobiertoParticipation"
          url_helpers.gobierto_participation_page_path({ id: slug }.merge(options))
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
          url_helpers.gobierto_participation_page_url({ id: slug, host: host }.merge(options))
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
      return "" if body_translations.nil?
      body = body_translations.values.join(" ").tr("\n\r", " ").gsub(/\s+/, " ")
      body = strip_tags(body)
      body[0..9300]
    end
  end
end
