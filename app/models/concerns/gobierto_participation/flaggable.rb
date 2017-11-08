# frozen_string_literal: true

module GobiertoParticipation
  module Flaggable
    extend ActiveSupport::Concern

    included do
      has_many :flags, as: :flaggable
      scope :flagged, -> { where("flags_count > 0") }

      def flagged_by_user?(user)
        flags.where(user_id: user.id).any?
      end
    end
  end
end
