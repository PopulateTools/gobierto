# frozen_string_literal: true

module GobiertoCalendars
  class EventLocation < ApplicationRecord
    belongs_to :event, optional: true

    validates :name, presence: true

    def geolocated?
      lat.present? && lng.present?
    end
  end
end
