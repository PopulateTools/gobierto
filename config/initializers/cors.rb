# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: false, logger: (-> { Rails.logger }) do
  allow do
    origins "*"

    resource "/api/*",
      :headers => :any,
      :methods => [:get, :post, :delete, :put, :patch, :options, :head],
      :max_age => 0
  end
end
