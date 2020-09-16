# frozen_string_literal: true

module GobiertoPeople
  class PersonPost < ApplicationRecord
    include User::Subscribable
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Searchable
    include GobiertoCommon::Sluggable

    validates :person, presence: true
    validates :site, presence: true
    validates :slug, uniqueness: { scope: :site_id }

    multisearchable(
      against: [:title, :body],
      additional_attributes: lambda { |item|
        {
          site_id: item.site_id,
          title_translations: item.truncated_translations(:title),
          description_translations: item.truncated_translations(:body),
          resource_path: item.resource_path,
          searchable_updated_at: item.updated_at
        }
      },
      if: :searchable?
    )

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
