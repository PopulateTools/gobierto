# frozen_string_literal: true

module GobiertoParticipation
  class VotePolicy
    attr_reader :current_user

    def initialize(current_user)
      @current_user = current_user
    end

    def create?
      return false unless @current_user.present?

      true
    end
  end
end
