# frozen_string_literal: true

source "https://rubygems.org"

gem "actionpack-action_caching"
gem "active_model_serializers"
gem "bcrypt", "~> 3.1.0"
gem "cookies_eu"
gem "dalli"
gem "ine-places", "0.3.0"
gem "jbuilder", "~> 2.5"
gem "mechanize"
gem "meta-tags"
gem "paper_trail"
gem "paranoia"
gem "pg", "~> 1.1"
gem "rails", "~> 5.2.1"
gem "redcarpet", require: true
gem "responders"
gem "rollbar"
gem "ruby_px"
gem "before_renders"
gem "bootsnap"

# Frontend
gem "bourbon", "~> 4.3.4"
gem "cocoon"
gem "d3-rails", "~> 4.8"
gem "flight-for-rails"
gem "i18n-js", ">= 3.0.0.rc11"
gem "jquery-rails"
gem "sass-rails", "~> 5.0.0"
gem "therubyracer"
gem "turbolinks"
gem "uglifier", ">= 1.3.0"
gem "chroma"

# Webpack
gem "webpacker", "~> 3.0", git: "https://github.com/ferblape/webpacker.git", branch: "3-x-stable"

# Elasticsearch
gem "elasticsearch"
gem "elasticsearch-extensions"

# Background processing
gem "sidekiq", "~> 5.2.1"
gem "sidekiq-monitor-stats"

# AWS SDK client
gem "aws-sdk", "~> 2.6", require: false

# AWS SES client
gem "aws-ses", "~> 0.6.0"

# Calendar view component
gem "simple_calendar", "~> 2.2"

# Algolia client
gem "algoliasearch-rails", "~> 1.17"
# Algolia client indexing sanitizer
gem "rails-html-sanitizer"

# Pagination
gem "kaminari", "~> 1.0"

# Captcha
gem "invisible_captcha"

# Redis
gem "redis", "~> 4.0"

# Translations
gem "json_translate", "~> 4.0"

# Liquid
gem "liquid", "~> 4.0"
gem "liquid-rails", "~> 0.2.0"

# Google API
gem "geocoder"
gem "google-api-client"

# Microsoft Exchange calendars
gem "exchanger"

# Web Services
gem "savon", "~> 2.11.1"

# Image management
gem "cloudinary"

# Gobierto data
gem "gobierto_data", git: "https://github.com/PopulateTools/gobierto_data.git"

group :development, :test do
  gem "byebug", platform: :mri
  gem "i18n-tasks"
  gem "spring"
  gem "puma"
end

group :test do
  gem "capybara"
  gem "capybara-email"
  gem "codecov", "~> 0.1.9", require: false
  gem "launchy"
  gem "minitest", "5.11.3"
  gem "minitest-reporters"
  gem "minitest-retry"
  gem "minitest-stub_any_instance"
  gem "minitest-stub-const"
  gem "mocha"
  gem "poltergeist"
  gem "spy"
  gem "timecop"
  gem "vcr"
  gem "webmock"
end

group :development do
  gem "rubocop"
  gem "listen"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "foreman"
end
