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
        existing_location = find_by(external_id: location.place_id.to_s) || find_by_meta(location)
        if existing_location.present?
          if existing_location.external_id.blank?
            existing_location.update_attribute(:external_id, location.place_id.to_s)
            existing_location.update_attribute(:meta, metadata(location))
          end

          existing_location.add_name(name)

          existing_location
        else
          create(
            names: [name],
            meta: metadata(location),
            external_id: location.place_id.to_s
          )
        end
      end
    end

    def self.create_from_meta(meta)
      meta = meta.with_indifferent_access
      locations = where(external_id: nil).where("meta @> ?", meta.slice(:lat, :lon, :city_name).to_json)
      if locations.exists?
        locations.first
      else
        create(
          names: [meta[:name]],
          meta: meta.slice(:lat, :lon, :city_name, :country_code, :country_name, :types)
        )
      end
    end

    def self.find_by_meta(location)
      where(external_id: nil).where("meta @> ?", metadata(location).slice(:lat, :lon, :city_name).to_json).first
    end

    def self.metadata(location)
      {
        lat: location.latitude,
        lon: location.longitude,
        city_name: location.city,
        country_code: location.country_code.upcase,
        country_name: location.country,
        types: (location.try(:types) || [location.try(:type)]).compact
      }
    end

    def add_name(name)
      return if names.is_a?(Array) && names.include?(name)

      if names.is_a?(Array)
        names << name
      else
        self.names = [name]
      end
      save
    end
  end
end
