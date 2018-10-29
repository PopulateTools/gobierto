# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class PersonPost < ApplicationRecord
    include User::Subscribable
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Searchable
    include GobiertoCommon::Sluggable

    validates :person, presence: true
    validates :site, presence: true
    validates :slug, uniqueness: { scope: :site }

    algoliasearch_gobierto do
      attribute :site_id, :title, :body, :updated_at
      searchableAttributes ['title', 'body']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    belongs_to :person, counter_cache: :posts_count
    belongs_to :site

    scope :sorted, -> { order(created_at: :desc) }
    scope :by_tag, ->(*tags) { where("tags @> ARRAY[?]::varchar[]", tags) }

    delegate :site_id, to: :person
    delegate :admin_id, to: :person

    enum visibility_level: { draft: 0, active: 1 }

    def parameterize
      { person_slug: person.slug, slug: slug }
    end

    def attributes_for_slug
      [Time.now.strftime("%F"), title]
    end

    def resource_path
      url_helpers.gobierto_people_person_post_url({ person_slug: person.slug, slug: slug }.merge(host: site.domain))
    end

    def public?
      active? && person.reload.active?
    end
  end
end
