# frozen_string_literal: true

Geocoder.configure(
  lookup: :google,
  api_key: Rails.application.secrets.google_maps_geocoding_api_key || "",
  timeout: 5,
  units: :km
)
