# frozen_string_literal: true

require_dependency "gobierto_participation"

module GobiertoParticipation
  class Contribution < ApplicationRecord
    include GobiertoCommon::Searchable
    include GobiertoCommon::Sluggable
    include GobiertoParticipation::Flaggable
    include GobiertoParticipation::Votable

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
    validates_length_of :title, maximum: 140

    scope :sort_by_created_at, -> { reorder(created_at: :desc) }
    scope :created_at_last_week, -> { where("created_at >= ?", 1.week.ago) }
    scope :with_user, ->(user) { where("user_id = ?", user.id) }

    def self.loved
      ids = Contribution.all.select { |c| c.love_pct >= 50 }.map(&:id)
      where(id: ids)
    end

    def self.hated
      ids = Contribution.all.select { |c| c.hate_pct >= 20 }.map(&:id)
      where(id: ids)
    end

    def active?
      true
    end

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

    def resource_path
      Rails.application.routes.url_helpers.gobierto_participation_process_process_contribution_container_process_contribution_path(
        process_id: contribution_container.process.slug,
        process_contribution_container_id: contribution_container.slug,
        id: slug
      )
    end

    def votes_fdiv(numerator, denominator, args = {})
      fallback = args.fetch(:fallback) { 0 }
      round = args.fetch(:round) { 2 }
      percentage = args.fetch(:percentage) { false }
      multiplier = percentage ? 100 : 1

      return fallback unless numerator.is_a?(Numeric) && denominator.is_a?(Numeric)
      return fallback if denominator.negative?

      (numerator.fdiv(denominator) * multiplier).round(round)
    end

    def love_pct
      love_votes = votes.where(vote_weight: 2).count
      all_votes = votes.count

      pct = votes_fdiv(love_votes, all_votes, percentage: true, fallback: 0)

      if pct.nan?
        0
      else
        pct
      end
    end

    def like_pct
      like_votes = votes.where(vote_weight: 1).count
      all_votes = votes.count

      pct = votes_fdiv(like_votes, all_votes, percentage: true, fallback: 0)

      if pct.nan?
        0
      else
        pct
      end
    end

    def neutral_pct
      neutral_votes = votes.where(vote_weight: 0).count
      all_votes = votes.count

      pct = votes_fdiv(neutral_votes, all_votes, percentage: true, fallback: 0)

      if pct.nan?
        0
      else
        pct
      end
    end

    def hate_pct
      hate_votes = votes.where(vote_weight: -1).count
      all_votes = votes.count

      pct = votes_fdiv(hate_votes, all_votes, percentage: true, fallback: 0)

      if pct.nan?
        0
      else
        pct
      end
    end

    def created_at_ymd
      created_at.strftime("%Y-%m-%d")
    end

    def self.javascript_json
      all.to_json(only: [:title, :votes_count, :user_id], methods: [:resource_path, :love_pct, :like_pct, :neutral_pct, :hate_pct, :created_at_ymd])
    end
  end
end
