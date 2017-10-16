# frozen_string_literal: true

module GobiertoParticipation
  class VoteForm
    include ActiveModel::Model

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

    protected

    def promote_errors(errors_hash)
      errors_hash.each do |attribute, message|
        errors.add(attribute, message)
      end
    end
  end
end
