require_dependency "gobierto_people"

module GobiertoPeople
  class PersonEvent < ApplicationRecord
    include User::Subscribable
    include AlgoliaSearch
    include AlgoliaSearchGobierto
    include Rails.application.routes.url_helpers

    algoliasearch_gobierto do
      attribute :site_id, :title, :description
      add_attribute :resource_path, :class_name
    end

    belongs_to :person, counter_cache: :events_count

    has_many :locations, class_name: "PersonEventLocation", dependent: :destroy
    has_many :attendees, class_name: "PersonEventAttendee", dependent: :destroy

    scope :past,     -> { published.where("starts_at <= ?", Time.zone.now) }
    scope :upcoming, -> { published.where("starts_at > ?", Time.zone.now) }
    scope :sorted,   -> { order(starts_at: :asc) }
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

    enum state: { pending: 0, published: 1 }

    def parameterize
      { person_id: person, id: self }
    end

    def past?
      starts_at <= Time.zone.now
    end

    def upcoming?
      starts_at > Time.zone.now
    end

    private

    def resource_path
      gobierto_people_person_event_path(person.id, self.id)
    end
  end
end
