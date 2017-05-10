require_dependency "gobierto_people"

module GobiertoPeople
  class PersonPost < ApplicationRecord
    include User::Subscribable
    include GobiertoCommon::Searchable
    include GobiertoPeople::SearchableBySlug

    algoliasearch_gobierto do
      attribute :site_id, :title, :body, :updated_at
      searchableAttributes ['title', 'body']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    belongs_to :person, counter_cache: :posts_count

    scope :sorted, -> { order(created_at: :desc) }
    scope :by_tag, ->(*tags) { where("tags @> ARRAY[?]::varchar[]", tags) }

    delegate :site_id, to: :person
    delegate :admin_id, to: :person

    enum visibility_level: { draft: 0, active: 1 }

    before_save :set_slug

    def parameterize
      { person_id: person, id: self }
    end

    private

    def set_slug
      if slug.nil?
        new_slug = GobiertoPeople::PersonPost.generate_unique_slug(title, Time.zone.now)
        write_attribute(:slug, new_slug)
      end
    end

  end
end
