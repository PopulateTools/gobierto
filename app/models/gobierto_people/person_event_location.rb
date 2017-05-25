# frozen_string_literal: true

require_dependency 'gobierto_people'

module GobiertoPeople
  class PersonEventLocation < ApplicationRecord
    belongs_to :person_event

    validates :name, presence: true

    def geolocated?
      lat.present? && lng.present?
    end
  end
end
