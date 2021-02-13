# frozen_string_literal: true

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

    multisearchable(
      against: [:name, :charge_es, :charge_en, :charge_ca, :bio_es, :bio_en, :bio_ca],
      additional_attributes: lambda { |item|
        {
          site_id: item.site_id,
          title_translations: item.truncated_translations(:name),
          description_translations: item.truncated_translations(:bio),
          resource_path: item.resource_path,
          searchable_updated_at: item.updated_at
        }
      },
      if: :searchable?
    )

    belongs_to :admin, class_name: "GobiertoAdmin::Admin", optional: true
    belongs_to :site
    has_vocabulary :political_groups, optional: true

    has_many :attending_person_events, class_name: "GobiertoCalendars::EventAttendee", dependent: :destroy
    has_many :attending_events, class_name: "GobiertoCalendars::Event", through: :attending_person_events, source: :event

    has_many :statements, class_name: "PersonStatement", dependent: :destroy
    has_many :posts, class_name: "PersonPost", dependent: :destroy

    has_many :received_gifts, class_name: "Gift", dependent: :destroy
    has_many :invitations, dependent: :destroy
    has_many :trips, dependent: :destroy
    has_many :historical_charges, dependent: :destroy, class_name: "GobiertoPeople::Charge"

    scope :sorted, -> { order(position: :asc, created_at: :desc) }
    scope :by_site, ->(site) { where(site_id: site.id) }
    scope :with_event_attendances, ->(site) { where(id: site.event_attendances.pluck(:person_id).uniq) }
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

    def owned_attending_events
      attending_events.person_events.where(collection_items: { container_id: id })
    end

    def historical_charge(date = nil)
      if date.present?
        historical_charges.on_date(date).take
      else
        historical_charge(Date.current) || historical_charges.reverse_sorted.first
      end
    end

    def charge(date = nil)
      if historical_charges.exists?
        historical_charge(date)&.name
      else
        return if charge_translations.blank?

        charge_translations.fetch(I18n.locale, charge_translations&.values&.first)
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
