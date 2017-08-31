# frozen_string_literal: true

module GobiertoParticipation
  module Votable
    extend ActiveSupport::Concern

    included do
      has_many :votes, as: :votable

      def vote_by_user?(user)
        votes.where(user_id: user.id).any?
      end
    end
  end
end
