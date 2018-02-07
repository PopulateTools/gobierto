# frozen_string_literal: true

module GobiertoParticipation
  class ProcessDecorator < BaseDecorator
    def initialize(process)
      @object = process
    end

    def interactions_count
      related_contributions.size + related_comments.size
    end

    def participants_count
      (
        related_contributions.pluck(:user_id) +
        related_comments.pluck(:user_id) +
        related_votes.pluck(:user_id)
      ).uniq.size
    end

    private

    def related_contributions
      site.contributions.where(contribution_container: contribution_containers)
    end

    def related_comments
      site.comments.where(commentable: related_contributions)
    end

    def related_votes
      site.votes.where(votable: related_comments)
    end
  end
end
