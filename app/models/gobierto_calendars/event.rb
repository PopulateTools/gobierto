require_dependency "gobierto_calendars"

module GobiertoCalendars
  class Event < ApplicationRecord
    paginates_per 8

    attr_accessor :admin_id

    include User::Subscribable
    include GobiertoCommon::Searchable
    include GobiertoCommon::Sluggable
    include GobiertoCommon::Collectionable

    validates :site, :collection, presence: true

    translates :title, :description

    algoliasearch_gobierto do
      attribute :site_id, :title_en, :title_es, :title_ca, :description_en, :description_es, :description_ca, :updated_at
      searchableAttributes ['title_en', 'title_es', 'title_ca', 'description_en', 'description_es', 'description_ca']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    belongs_to :site
    belongs_to :collection, class_name: "GobiertoCommon::Collection"
    has_many :locations, class_name: "EventLocation", dependent: :destroy
    has_many :attendees, class_name: "EventAttendee", dependent: :destroy

    after_create :add_item_to_collection

    scope :past,     -> { published.where("starts_at <= ?", Time.zone.now) }
    scope :upcoming, -> { published.where("starts_at > ?", Time.zone.now) }
    scope :sorted,   -> { order(starts_at: :asc) }
    scope :sorted_backwards, -> { order(starts_at: :desc) }
    scope :within_range, -> (date_range) { published.where(starts_at: date_range) }
    scope :synchronized, -> { where("external_id IS NOT NULL") }
    scope :by_date,  ->(date) { where("starts_at::date = ?", date) }
    scope :sort_by_updated_at, -> { order(updated_at: :desc) }
    scope :inverse_sorted_by_id, -> { order(id: :asc) }
    scope :sorted_by_id, -> { order(id: :desc) }

    scope :by_collection, ->(collection) do
      where(collection_id: collection.id)
    end

    scope :by_site, ->(site) do
      where(site_id: site.id)
    end

    scope :by_person_category, ->(category) do
      where(collection_id: ::GobiertoPeople::Person.where(category: category).map{ |p| p.events_collection.id})
    end

    scope :by_person_party, ->(party) do
      where(collection_id: ::GobiertoPeople::Person.where(party: party).map{ |p| p.events_collection.id})
    end

    scope :person_events, -> do
      joins("INNER JOIN collection_items ON
          collection_items.container_type = 'GobiertoPeople::Person' AND
          collection_items.item_type = 'GobiertoCalendars::Event' AND
          collection_items.item_id = #{self.table_name}.id")
    end

    enum state: { pending: 0, published: 1 }

    def self.events_in_collections_and_container_type(site, container_type)
      ids = GobiertoCommon::CollectionItem.where(item_type: "GobiertoCalendars::Event", container_type: container_type).pluck(:item_id)
      where(id: ids, site: site).published
    end

    def self.events_in_collections_and_container(site, container)
      ids = GobiertoCommon::CollectionItem.where(item_type: "GobiertoCalendars::Event", container: container).pluck(:item_id)
      where(id: ids, site: site).published
    end

    def parameterize
      { container_slug: collection.container.slug, slug: slug }
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
      [:id, :collection_title, :creator_type, :creator_id, :creator_name, :title, :description, :starts_at, :ends_at, :attachment_url, :created_at, :updated_at]
    end

    def as_csv
      [id, collection.title, collection.container.class.name, collection.container.id, collection.container.name, title, description, starts_at, ends_at, attachment_url, created_at, updated_at]
    end

    def attributes_for_slug
      [starts_at.strftime('%F'), title]
    end

    def add_item_to_collection
      collection.append(self)
    end

    def to_path
      url_helpers.gobierto_people_person_event_path(parameterize)
    end
    alias_method :resource_path, :to_path

    def to_url(options = {})
      if collection.container_type == "GobiertoParticipation::Process"
        url_helpers.gobierto_participation_process_event_url({ id: slug, process_id: collection.container.slug, host: app_host }.merge(options))
      elsif collection.container_type == "GobiertoParticipation"
        url_helpers.gobierto_participation_event_url({ id: slug, host: app_host }.merge(options))
      else
        url_helpers.gobierto_people_person_event_url(parameterize.merge(host: app_host).merge(options))
      end
    end

    def first_location
      locations.first
    end

    def first_issue
      collection_item = GobiertoCommon::CollectionItem.where(item: self, container_type: "Issue").first

      collection_item.container if collection_item
    end
  end
end
