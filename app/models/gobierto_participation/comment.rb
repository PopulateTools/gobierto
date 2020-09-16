# frozen_string_literal: true

module GobiertoParticipation
  class Comment < ApplicationRecord
    include GobiertoParticipation::Flaggable
    include GobiertoParticipation::Votable

    belongs_to :commentable, polymorphic: true, counter_cache: true
    belongs_to :user
    belongs_to :site

    validates :body, :user, presence: true

    def positive_votes
      votes.where(vote_weight: 1).size
    end

    def negative_votes
      votes.where(vote_weight: -1).size
    end

    def contribution_container
      commentable.contribution_container
    end

    def slug
      commentable.slug
    end

    def replies
      GobiertoParticipation::Comment.where(commentable: self)
    end
  end
end
