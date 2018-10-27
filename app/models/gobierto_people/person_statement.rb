# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class PersonStatement < ApplicationRecord
    include ::GobiertoCommon::DynamicContent
    include User::Subscribable
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Searchable
    include GobiertoCommon::Sluggable

    validates :person, :site, presence: true
    validates :slug, uniqueness: { scope: :site }

    translates :title

    algoliasearch_gobierto do
      attribute :site_id, :title_en, :title_es, :title_ca, :updated_at
      searchableAttributes ['title_en', 'title_es', 'title_ca']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    belongs_to :person, counter_cache: :statements_count
    belongs_to :site

    scope :sorted, -> { order(published_on: :desc, created_at: :desc) }
    scope :sorted_by_person_position, -> { joins(:person).order("#{Person.table_name}.position ASC, published_on DESC, #{table_name}.created_at DESC") }

    enum visibility_level: { draft: 0, active: 1 }

    delegate :site_id, to: :person
    delegate :admin_id, to: :person

    def parameterize
      { person_slug: person.slug, slug: slug }
    end

    def self.csv_columns
      [:id, :person_id, :person_name, :title, :published_on, :attachment_url, :attachment_size, :created_at, :updated_at]
    end

    def as_csv
      person_name = person.try(:name)

      [id, person_id, person_name, title, published_on, attachment_url, attachment_size, created_at, updated_at]
    end

    def attributes_for_slug
      [Time.now.strftime("%F"), title]
    end

    def resource_path
      url_helpers.gobierto_people_person_statement_url({ person_slug: person.slug, slug: slug }.merge(host: site.domain))
    end

    def public?
      active? && person.reload.active?
    end
  end
end
