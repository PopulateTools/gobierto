# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class Contribution < ApplicationRecord
    include GobiertoParticipation::Flaggable
    include GobiertoCommon::Searchable
    include GobiertoCommon::Sluggable

    belongs_to :user
    belongs_to :site
    belongs_to :contribution_container
    has_many :comments, as: :commentable
    has_many :votes, as: :votable

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title, :description
      searchableAttributes ["title", "description"]
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    validates :title, :description, :user, :contribution_container, presence: true

    scope :sort_by_created_at, -> { reorder(created_at: :desc) }
    # scope :sort_by_votes , -> { reorder(hot_score: :desc) }

    def parameterize
      { slug: slug }
    end

    def attributes_for_slug
      [title]
    end

    def number_participants
      user_ids = comments.map(&:user_id) + votes.map(&:user_id)
      user_ids.uniq
      user_ids.size
    end
  end
end
