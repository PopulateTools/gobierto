# frozen_string_literal: true

module GobiertoParticipation
  class VotePolicy
    attr_reader :current_user, :votable

    def initialize(current_user, votable)
      @current_user = current_user
      @votable = votable
    end

    def create?
      return false unless @current_user.present?
      return false if @votable.voted_by_user?(@current_user)
      true
    end
  end
end
