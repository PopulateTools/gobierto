# frozen_string_literal: true

module GobiertoParticipation
  class VotePolicy
    attr_reader :current_user, :votable

    def initialize(current_user, votable, vote_weight)
      @current_user = current_user
      @votable = votable
      @vote_weight = vote_weight
    end

    def create?
      return false unless @current_user.present?
      return false if @votable.voted_by_user?(@current_user, @vote_weight)
      true
    end
  end
end
