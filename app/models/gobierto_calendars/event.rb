# frozen_string_literal: true

require_dependency "gobierto_calendars"

module GobiertoCalendars
  class Event < ApplicationRecord
    acts_as_paranoid column: :archived_at

    paginates_per 8
    ADMIN_PAGE_SIZE = 40

    attr_accessor :admin_id

    include ActsAsParanoidAliases
    include User::Subscribable
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Searchable
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Collectionable
    include GobiertoCommon::Metadatable
    include GobiertoAttachments::Attachable

    validates :site, :collection, presence: true
    validates :slug, uniqueness: { scope: :site_id }


    translates :title, :description

    metadata_attributes :type

    algoliasearch_gobierto do
      attribute :site_id, :title_en, :title_es, :title_ca, :searchable_description, :updated_at
      searchableAttributes ['title_en', 'title_es', 'title_ca', 'searchable_description']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    belongs_to :site
    belongs_to :department, class_name: "GobiertoPeople::Department"
    belongs_to :interest_group, class_name: "GobiertoPeople::InterestGroup"
    has_many :locations, class_name: "EventLocation", dependent: :destroy
    has_many :attendees, class_name: "EventAttendee", dependent: :destroy

    after_create :add_item_to_collection
    after_restore :set_slug

    scope :past,     -> { published.where("starts_at <= ?", Time.zone.now) }
    scope :upcoming, -> { published.where("starts_at > ?", Time.zone.now) }
    scope :sorted,   -> { order(starts_at: :asc) }
    scope :sorted_backwards, -> { order(starts_at: :desc) }
    scope :within_range, ->(date_range) { published.where(starts_at: date_range) }
    scope :synchronized, -> { where("external_id IS NOT NULL") }
    scope :by_date, ->(date) { where("starts_at::date = ?", date) }
    scope :sort_by_updated_at, -> { order(updated_at: :desc) }
    scope :inverse_sorted_by_id, -> { order(id: :asc) }
    scope :sorted_by_id, -> { order(id: :desc) }
    scope :with_interest_group, -> { where.not(interest_group_id: nil) }
    scope :with_department, -> { where.not(department_id: nil) }

    scope :by_collection, ->(collection) { where(collection_id: collection.id) }
    scope :by_site, ->(site) { where(site_id: site.id) }

    scope :by_person_category, ->(category) do
      collection_ids = ::GobiertoPeople::Person.where(category: category).map { |p| p.events_collection.id }
      where(collection_id: collection_ids)
    end

    scope :by_person_party, ->(party) do
      collection_ids = ::GobiertoPeople::Person.where(party: party).map { |p| p.events_collection.id }
      where(collection_id: collection_ids)
    end

    scope :person_events, -> do
      joins("INNER JOIN collection_items ON
          collection_items.container_type = 'GobiertoPeople::Person' AND
          collection_items.item_type = 'GobiertoCalendars::Event' AND
          collection_items.item_id = #{table_name}.id")
    end

    enum state: { pending: 0, published: 1 }

    def self.events_in_collections_and_container_type(site, container_type)
      ids = GobiertoCommon::CollectionItem.events.by_container_type(container_type).pluck(:item_id)
      where(id: ids, site: site).published
    end

    def self.events_in_collections_and_container(site, container)
      events_in_collections_and_container_with_pending(site, container).published
    end

    def self.events_in_collections_and_container_with_pending(site, container)
      ids = GobiertoCommon::CollectionItem.events.by_container(container).pluck(:item_id)
      where(id: ids, site: site)
    end

    def parameterize
      { container_slug: container.slug, slug: slug }
    end

    def past?
      starts_at <= Time.zone.now
    end

    def upcoming?
      starts_at > Time.zone.now
    end

    def active?
      published?
    end

    def synchronized?
      external_id.present?
    end

    def self.csv_columns
      [:id, :collection_title, :creator_type, :creator_id, :creator_name, :title, :description, :starts_at, :ends_at, :created_at, :updated_at]
    end

    def as_csv
      [id, collection.title, container.class.name, container.id, container.name, title, description, starts_at, ends_at, created_at, updated_at]
    end

    def attributes_for_slug
      [Time.now.strftime("%F"), title]
    end

    def add_item_to_collection
      collection.append(self)
    end

    def to_path
      if collection.container_type == "GobiertoParticipation::Process"
        url_helpers.gobierto_participation_process_event_path(id: slug, process_id: container.slug)
      elsif collection.container_type == "GobiertoParticipation"
        url_helpers.gobierto_participation_event_path(id: slug)
      else
        url_helpers.gobierto_people_person_event_path(parameterize)
      end
    end
    alias resource_path to_path

    def to_url(options = {})
      if !public? && options[:preview] && options[:admin]
        options[:preview_token] = options[:admin].preview_token
      end
      options = options.except(:admin, :preview)

      if collection.container_type == "GobiertoParticipation::Process"
        url_helpers.gobierto_participation_process_event_url({ id: slug, process_id: container.slug, host: site_domain }.merge(options))
      elsif collection.container_type == "GobiertoParticipation"
        url_helpers.gobierto_participation_event_url({ id: slug, host: site_domain }.merge(options))
      else
        url_helpers.gobierto_people_person_event_url(parameterize.merge(host: site_domain).merge(options))
      end
    end

    def first_location
      locations.first
    end

    def searchable_description
      searchable_translated_attribute(description_translations)
    end

    def public?
      public_parent? && active?
    end

    private

    def site_domain
      site.domain
    end

    def public_parent?
      if process
        process.reload.public?
      elsif person
        person.reload.public?
      else
        true
      end
    end

  end
end
