require_dependency "gobierto_people"

module GobiertoPeople
  class PersonEvent < ApplicationRecord
    paginates_per 8

    include User::Subscribable
    include GobiertoCommon::Searchable
    include GobiertoPeople::Sluggable

    validates :person, presence: true
    validates :site, presence: true

    translates :title, :description

    algoliasearch_gobierto do
      attribute :site_id, :title_en, :title_es, :title_ca, :description_en, :description_es, :description_ca, :updated_at
      searchableAttributes ['title_en', 'title_es', 'title_ca', 'description_en', 'description_es', 'description_ca']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    belongs_to :person, counter_cache: :events_count
    belongs_to :site

    has_many :locations, class_name: "PersonEventLocation", dependent: :destroy
    has_many :attendees, class_name: "PersonEventAttendee", dependent: :destroy

    scope :past,     -> { published.where("starts_at <= ?", Time.zone.now) }
    scope :upcoming, -> { published.where("starts_at > ?", Time.zone.now) }
    scope :sorted,   -> { order(starts_at: :asc) }
    scope :sorted_backwards, -> { order(starts_at: :desc) }
    scope :within_range, -> (date_range) { published.where(starts_at: date_range) }
    scope :synchronized, -> { where("external_id IS NOT NULL") }
    scope :by_date,  ->(date) { where("starts_at::date = ?", date) }

    scope :by_site, ->(site) do
      joins(:person).where(Person.table_name => { site_id: site.id })
    end

    scope :by_person_category, ->(category) do
      joins(:person).where(Person.table_name => { category: category })
    end

    scope :by_person_party, ->(party) do
      joins(:person).where(Person.table_name => { party: party })
    end

    delegate :site_id, to: :person
    delegate :admin_id, to: :person

    enum state: { pending: 0, published: 1 }

    def parameterize
      { person_slug: person.slug, slug: slug }
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
      [:id, :person_id, :person_name, :title, :description, :starts_at, :ends_at, :attachment_url, :created_at, :updated_at]
    end

    def as_csv
      person_name = person.try(:name)

      [id, person_id, person_name, title, description, starts_at, ends_at, attachment_url, created_at, updated_at]
    end

    def attributes_for_slug
      [starts_at.strftime('%F'), title]
    end

  end
end
