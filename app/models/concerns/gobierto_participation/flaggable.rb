# frozen_string_literal: true

module GobiertoParticipation
  module Flaggable
    extend ActiveSupport::Concern

    included do
      has_many :flags, as: :flaggable
      scope :flagged, -> { where("flags_count > 0") }
    end
  end
end
