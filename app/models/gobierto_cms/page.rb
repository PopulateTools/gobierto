require_dependency "gobierto_cms"

module GobiertoCms
  class Page < ApplicationRecord
    include User::Subscribable
    include GobiertoCommon::Searchable

    algoliasearch_gobierto do
      attribute :site_id, :title, :body, :updated_at
      searchableAttributes ['title', 'body']
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    belongs_to :site

    enum visibility_level: { draft: 0, active: 1 }

    validates :site, :title, :body, :slug, presence: true

    scope :sorted, -> { order(id: :desc) }

    def to_param
      self.slug
    end
  end
end
