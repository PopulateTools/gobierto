# frozen_string_literal: true

require_dependency "gobierto_calendars"

module GobiertoCalendars
  class EventLocation < ApplicationRecord
    belongs_to :event

    validates :name, presence: true

    def geolocated?
      lat.present? && lng.present?
    end
  end
end
