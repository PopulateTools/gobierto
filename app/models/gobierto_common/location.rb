# frozen_string_literal: true

module GobiertoCommon
  class Location < ApplicationRecord
    include GobiertoCommon::Metadatable

    validates :external_id, uniqueness: { allow_nil: true }

    metadata_attributes(
      :lat,
      :lon,
      :city_name,
      :country_code,
      :country_name,
      :types
    )

    scope :by_name, ->(*names) { where("names @> ARRAY[?]::varchar[]", names) }

    def self.search(name)
      name = name.strip.gsub(/\s/, " ").squeeze(" ")
      cached_location = by_name(name)
      return cached_location.first if cached_location.exists?

      location = Geocoder.search(name).first

      if location.present?
        existing_location = find_by(external_id: location.place_id.to_s)
        if existing_location.present?
          existing_location.add_name(name)

          existing_location
        else
          create(
            names: [name],
            meta: {
              lat: location.latitude,
              lon: location.longitude,
              city_name: location.city,
              country_code: location.country_code.upcase,
              country_name: location.country,
              types: (location.try(:types) || [location.try(:type)]).compact
            },
            external_id: location.place_id.to_s
          )
        end
      end
    end

    def add_name(name)
      names << name
      save
    end
  end
end
