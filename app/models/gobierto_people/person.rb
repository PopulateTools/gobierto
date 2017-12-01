require_dependency "gobierto_people"

module GobiertoPeople
  class Person < ApplicationRecord
    include GobiertoCommon::DynamicContent
    include User::Subscribable
    include GobiertoCommon::Sortable
    include GobiertoCommon::Searchable
    include GobiertoCommon::Sluggable

    translates :charge, :bio

    algoliasearch_gobierto do
      attribute :site_id, :name, :charge_en, :charge_es, :charge_ca, :bio_en, :bio_es, :bio_ca, :updated_at
      searchableAttributes ['name', 'charge_en', 'charge_es', 'charge_ca', 'bio_en', 'bio_es', 'bio_ca']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    belongs_to :admin, class_name: "GobiertoAdmin::Admin"
    belongs_to :site
    belongs_to :political_group

    has_many :attending_person_events, class_name: "GobiertoCalendars::EventAttendee", dependent: :destroy
    has_many :attending_events, class_name: "GobiertoCalendars::Event", through: :attending_person_events, source: :event

    has_many :statements, class_name: "PersonStatement", dependent: :destroy
    has_many :posts, class_name: "PersonPost", dependent: :destroy

    has_one :calendar_configuration, class_name: "PersonCalendarConfiguration", dependent: :destroy

    scope :sorted, -> { order(position: :asc, created_at: :desc) }
    scope :by_site, ->(site) { where(site_id: site.id) }
    scope :with_calendar_configuration, -> { where('id IN (SELECT person_id FROM gp_person_calendar_configurations)') }

    enum visibility_level: { draft: 0, active: 1 }
    enum category: { politician: 0, executive: 1 }
    enum party: { government: 0, opposition: 1 }

    validates :email, format: { with: User::EMAIL_ADDRESS_REGEXP }, allow_blank: true
    validates :site, presence: true

    after_create :create_events_collection

    def self.csv_columns
      [:id, :name, :email, :charge, :bio, :bio_url, :avatar_url, :category, :political_group, :party, :created_at, :updated_at]
    end

    def self.presence_by_group_type
      [:visibility_levels, :categories, :parties].reduce({}) do |groups, key|
        enum_groups = send(key)
        groups.merge enum_groups.merge(enum_groups) { |group| self.send(group).any? }
      end
    end

    def as_csv
      political_group_name = political_group.try(:name)

      [id, name, email, charge, bio, bio_url, avatar_url, category, political_group_name, party, created_at, updated_at]
    end

    def parameterize
      { slug: slug }
    end

    def attributes_for_slug
      [name]
    end

    def events_collection
      @events_collection ||= GobiertoCommon::Collection.find_by container: self, item_type: 'GobiertoCalendars::Event'
    end

    def events
      GobiertoCalendars::Event.where(collection: events_collection)
    end

    def events_count
      events.count
    end

    def to_s
      self.name
    end

    private

    def create_events_collection
      site.collections.create! container_type: self.class.name, container_id: self.id,
        item_type: 'GobiertoCalendars::Event', slug: "calendar-#{self.slug}",
        title: self.name
    end
  end
end
