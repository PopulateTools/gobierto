# frozen_string_literal: true

Cloudinary.config do |config|
  config.cloud_name = Rails.application.secrets.cloudinary_cloud_name
  config.api_key = Rails.application.secrets.cloudinary_api_key
  config.api_secret = Rails.application.secrets.cloudinary_api_secret
  config.cdn_subdomain = true
end
