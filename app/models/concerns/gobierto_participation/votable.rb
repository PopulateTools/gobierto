# frozen_string_literal: true

module GobiertoParticipation
  module Votable
    extend ActiveSupport::Concern

    included do
      has_many :votes, as: :votable

      def voted_by_user?(user)
        votes.where(user_id: user.id).any?
      end

      def voted_with_weight_by_user?(user, vote_weight)
        votes.where(user_id: user.id, vote_weight: vote_weight).any?
      end
    end
  end
end
