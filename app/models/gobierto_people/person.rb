# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Person < ApplicationRecord
    include GobiertoCommon::DynamicContent
    include User::Subscribable
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Sortable
    include GobiertoCommon::Searchable
    include GobiertoCommon::Sluggable
    include GobiertoCommon::HasVocabulary

    translates :charge, :bio

    algoliasearch_gobierto do
      attribute :site_id, :name, :charge_en, :charge_es, :charge_ca, :bio_en, :bio_es, :bio_ca, :updated_at
      searchableAttributes ['name', 'charge_en', 'charge_es', 'charge_ca', 'bio_en', 'bio_es', 'bio_ca']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    belongs_to :admin, class_name: "GobiertoAdmin::Admin"
    belongs_to :site
    has_vocabulary :political_groups

    has_many :attending_person_events, class_name: "GobiertoCalendars::EventAttendee", dependent: :destroy
    has_many :attending_events, class_name: "GobiertoCalendars::Event", through: :attending_person_events, source: :event

    has_many :statements, class_name: "PersonStatement", dependent: :destroy
    has_many :posts, class_name: "PersonPost", dependent: :destroy

    has_many :received_gifts, class_name: "Gift", dependent: :destroy
    has_many :invitations, dependent: :destroy
    has_many :trips, dependent: :destroy

    scope :sorted, -> { order(position: :asc, created_at: :desc) }
    scope :by_site, ->(site) { where(site_id: site.id) }
    scope :with_event_attendances, -> { where(id: ::GobiertoCalendars::EventAttendee.pluck(:person_id)) }
    enum visibility_level: { draft: 0, active: 1 }
    alias public? active?
    enum category: { politician: 0, executive: 1 }
    enum party: { government: 0, opposition: 1 }

    validates :email, format: { with: User::EMAIL_ADDRESS_REGEXP }, allow_blank: true
    validates :site, :name, presence: true
    validates :slug, uniqueness: { scope: :site_id }

    after_create :create_events_collection

    def self.csv_columns
      [:id, :name, :email, :charge, :bio, :bio_url, :avatar_url, :category, :political_group, :party, :created_at, :updated_at]
    end

    def self.presence_by_group_type
      [:visibility_levels, :categories, :parties].reduce({}) do |groups, key|
        enum_groups = send(key)
        groups.merge enum_groups.merge(enum_groups) { |group| send(group).any? }
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
    alias calendar events_collection

    def calendar_configuration
      calendar.calendar_configuration
    end

    def events
      GobiertoCalendars::Event.where(collection: events_collection)
    end

    def events_count
      events.count
    end

    def to_s
      name
    end

    def statements_url(options = {})
      build_collection_url(options.merge(collection_key: :statements))
    end

    def blog_url(options = {})
      build_collection_url(options.merge(collection_key: :posts))
    end

    private

    def create_events_collection
      site.collections.create!(
        container_type: self.class.name,
        container_id: id,
        item_type: "GobiertoCalendars::Event",
        slug: "calendar-#{slug}",
        title: name
      )
    end

    def build_collection_url(options = {})
      if !public? && options[:preview] && options[:admin]
        options[:preview_token] = options[:admin].preview_token
      end

      url_helpers.send(
        "gobierto_people_person_#{options[:collection_key]}_url",
        options.merge(host: site.domain, person_slug: slug)
               .except(:preview, :admin, :collection_key)
      )
    end

  end
end
