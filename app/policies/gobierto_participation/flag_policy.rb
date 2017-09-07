# frozen_string_literal: true

module GobiertoParticipation
  class FlagPolicy
    attr_reader :current_user, :flagable

    def initialize(current_user, flaggable)
      @current_user = current_user
      @flaggable = flaggable
    end

    def create?
      return false unless @current_user.present?
      return false if @flaggable.flagged_by_user?(@current_user)
      true
    end
  end
end
