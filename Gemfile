# frozen_string_literal: true

source "https://rubygems.org"

gem "actionpack-action_caching"
gem "active_model_serializers"
gem "bcrypt", "~> 3.1.0"
gem "cookies_eu"
gem "dalli"
gem "hashie"
gem "ine-places", "0.3.0"
gem "jbuilder", "~> 2.5"
gem "mechanize"
gem "meta-tags"
gem "paper_trail"
gem "paranoia"
gem "pg", "~> 1.1"
gem "rails", "~> 6.0"
gem "redcarpet", require: true
gem "responders"
gem "rollbar"
gem "ruby_px"
gem "before_renders"
gem "bootsnap"
gem "truncate_html"
gem "rake", "~> 13.0"

# Frontend
gem "bourbon", "~> 7.0.0"
gem "sass", "~> 3.4"
gem "d3-rails", "~> 4.8"
gem "flight-for-rails"
gem "i18n-js", ">= 3.0.0.rc11"
gem "jquery-rails"
gem "sassc"
gem "therubyracer"
gem "turbolinks"
gem "uglifier", ">= 1.3.0"
gem "chroma"
gem "font-awesome-sass", "~> 5.6"

# Webpack
gem "webpacker", "~> 5.0"

# Elasticsearch
gem "elasticsearch", "~> 6.0", ">= 6.0.2"
gem "elasticsearch-extensions", "~> 0.0.27"

# Background processing
gem "sidekiq", "~> 5.2.7"
gem "sidekiq-monitor-stats"

# AWS SDK client
gem "aws-sdk-s3", "~> 1"

# AWS SES client
gem "aws-ses", "= 0.7.0"

# Calendar view component
gem "simple_calendar", "~> 2.2"

# Search client
gem "pg_search", "2.3.4"

# Search client indexing sanitizer
gem "rails-html-sanitizer"

# Pagination
gem "kaminari", "~> 1.2"

# Captcha
gem "invisible_captcha"

# Redis
gem "redis", "~> 4.0"

# Translations
gem "json_translate", "~> 4.0"
gem "route_translator"

# Liquid
gem "liquid", "~> 4.0"
gem "liquid-rails", git: "https://github.com/maierru/liquid-rails.git"

# Google API
gem "geocoder"
gem "google-api-client"

# Microsoft Exchange calendars
gem "exchanger"

# Web Services: Alcobendas, Valencia
gem "savon", "~> 2.12.0"

# Image management
gem "cloudinary"

# Gobierto data
gem "gobierto_data", git: "https://github.com/PopulateTools/gobierto_data.git"

# API
gem "rubyXL"

# Performance
gem "appsignal"

# Auth strategies
gem "net-ldap"
gem "ladle"

# Detect encoding
gem "charlock_holmes"

# CORS support
gem "rack-cors"

group :development, :test do
  gem "byebug", platform: :mri
  gem "i18n-tasks"
  gem "spring"
  gem "puma"
end

group :test do
  gem "capybara"
  gem "capybara-email"
  gem "codecov", "~> 0.2.0", require: false
  gem "launchy"
  gem "minitest", "5.14.2"
  gem "minitest-reporters"
  gem "minitest-retry"
  gem "minitest-stub_any_instance"
  gem "minitest-stub-const"
  gem "mocha"
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
