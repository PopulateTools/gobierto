# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class Contribution < ApplicationRecord
    include GobiertoParticipation::Flaggable
    include GobiertoCommon::Searchable

    belongs_to :user
    belongs_to :site
    belongs_to :contribution_container
    has_many :comments, as: :commentable

    algoliasearch_gobierto do
      attribute :site_id, :updated_at, :title, :description
      searchableAttributes ["title", "description"]
      attributesForFaceting [:site_id]
      add_attribute :resource_path, :class_name
    end

    validates :title, :description, :user, :contribution_container, presence: true

    scope :sort_by_created_at, -> { reorder(created_at: :desc) }
    # scope :sort_by_votes , -> { reorder(hot_score: :desc) }
  end
end
