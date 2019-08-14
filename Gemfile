# frozen_string_literal: true

source "https://rubygems.org"

gem "actionpack-action_caching", ">= 1.2.0"
gem "active_model_serializers", ">= 0.10.9"
gem "bcrypt", "~> 3.1.0"
gem "cookies_eu", ">= 1.7.5"
gem "dalli"
gem "hashie"
gem "ine-places", "0.3.0"
gem "jbuilder", "~> 2.5"
gem "mechanize", ">= 2.7.6"
gem "meta-tags", ">= 2.11.1"
gem "paper_trail"
gem "paranoia"
gem "pg", "~> 1.1"
gem "rails", "~> 5.2.3"
gem "redcarpet", require: true
gem "responders", ">= 3.0.0"
gem "rollbar"
gem "ruby_px"
gem "before_renders"
gem "bootsnap"
gem "truncate_html"

# Frontend
gem "bourbon", "~> 6.0.0"
gem "sass", "~> 3.4"
gem "d3-rails", "~> 4.8"
gem "flight-for-rails", ">= 1.5.1"
gem "i18n-js", ">= 3.0.0.rc11"
gem "jquery-rails", ">= 4.3.5"
gem "sassc"
gem "therubyracer"
gem "turbolinks"
gem "uglifier", ">= 1.3.0"
gem "chroma"
gem "font-awesome-sass", "~> 5.6"

# Webpack
gem "webpacker", "~> 4.0", ">= 4.0.7"

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
gem "simple_calendar", "~> 2.3", ">= 2.3.0"

# Algolia client
gem "algoliasearch-rails", "~> 1.17"
# Algolia client indexing sanitizer
gem "rails-html-sanitizer", ">= 1.0.4"

# Pagination
gem "kaminari", "~> 1.1", ">= 1.1.1"

# Captcha
gem "invisible_captcha", ">= 0.12.1"

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
gem "exchanger", ">= 0.2.1"

# Web Services
gem "savon", "~> 2.12.0"

# Image management
gem "cloudinary"

# Gobierto data
gem "gobierto_data", git: "https://github.com/PopulateTools/gobierto_data.git"

group :development, :test do
  gem "byebug", platform: :mri
  gem "i18n-tasks", ">= 0.9.29"
  gem "spring"
  gem "puma"
end

group :test do
  gem "capybara", ">= 3.26.0"
  gem "capybara-email", ">= 3.0.1"
  gem "codecov", "~> 0.1.9", require: false
  gem "launchy"
  gem "minitest", "5.11.3"
  gem "minitest-reporters"
  gem "minitest-retry"
  gem "minitest-stub_any_instance"
  gem "minitest-stub-const"
  gem "mocha"
  gem "rack-cors"
  gem "selenium-webdriver"
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
  gem "rb-readline"
end
