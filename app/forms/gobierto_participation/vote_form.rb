# frozen_string_literal: true

module GobiertoParticipation
  class VoteForm < BaseForm

    attr_accessor(
      :id,
      :site_id,
      :user_id,
      :votable_type,
      :votable_id,
      :vote_weight
    )

    delegate :persisted?, to: :vote

    validates :site, presence: true
    validate :contribution_container_must_be_open

    def save
      save_vote if valid?
    end

    def vote
      @vote ||= vote_class.find_by(id: id).presence || build_vote
    end

    def site_id
      @site_id ||= vote.site_id
    end

    def site
      @site ||= Site.find_by(id: site_id)
    end

    private

    def build_vote
      vote_class.new
    end

    def vote_class
      ::GobiertoParticipation::Vote
    end

    def votable_class
      votable_type.constantize
    end

    def contribution_class
      ::GobiertoParticipation::Contribution
    end

    def comment_class
      ::GobiertoParticipation::Comment
    end

    def save_vote
      @vote = vote.tap do |vote_attributes|
        vote_attributes.site_id = site_id
        vote_attributes.user_id = user_id
        vote_attributes.votable_type = votable_type
        vote_attributes.votable_id = votable_id
        vote_attributes.vote_weight = vote_weight
      end

      if @vote.valid?
        @vote.save

        @vote
      else
        promote_errors(@vote.errors)

        false
      end
    end

    def contribution_container
      if votable_type == contribution_class.to_s
        votable.contribution_container
      elsif votable_type == comment_class.to_s && votable.commentable_type == contribution_class.to_s
        votable.commentable.contribution_container
      end
    end

    def contribution_container_must_be_open
      if contribution_container.present? && !contribution_container.contributions_allowed?
        errors.add(:contribution_container, "Contributions period has finished")
      end
    end

    def votable
      votable_class.find(votable_id)
    end

  end
end
