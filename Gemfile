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
gem "rails", "~> 6.0.4.8"
gem "redcarpet", require: true
gem "responders"
gem "rollbar"
gem "ruby_px"
gem "before_renders"
gem "bootsnap"
gem "truncate_html"
gem "rake", "~> 13.0"

# Frontend
gem "i18n-js", ">= 3.0.0.rc11" # required to i18n-tasks

# Webpack
gem "webpacker", "~> 5.0"

# Elasticsearch
gem "elasticsearch", "~> 6.0", ">= 6.0.2"
gem "elasticsearch-extensions", "~> 0.0.27"

# Background processing
gem "sidekiq"
gem "sidekiq-monitor-stats"

# AWS SDK client
gem "aws-sdk-s3", "~> 1"

# AWS SES client
gem "aws-ses", git: "https://github.com/zebitex/aws-ses.git", ref: "78-sigv4-problem"

# Calendar view component
gem "simple_calendar", "~> 2.2"

# Search client
gem "pg_search", "2.3.5"

# Search client indexing sanitizer
gem "rails-html-sanitizer"

# Pagination
gem "kaminari", "~> 1.2"

# Captcha
gem "invisible_captcha"

# Redis
gem "redis"

# Translations
gem "json_translate"
gem "route_translator"

# Liquid
gem "liquid", "~> 4.0"
gem "liquid-rails", git: "https://github.com/maierru/liquid-rails.git"

# Google API
gem "geocoder", ">= 1.8.2"
gem "google-api-client"

# Microsoft Exchange calendars
gem "exchanger"

# Web Services: Alcobendas, Valencia
gem "savon", "~> 2.12.0"

# Gobierto budgets data
gem "gobierto_budgets_data", git: "https://github.com/PopulateTools/gobierto_budgets_data.git"

# API
gem "rubyXL"

# Performance
# TODO: v3 raises a middleware error
gem "appsignal", "= 3.0.6"

# Analytics
gem 'ahoy_matey', '~> 4.2', '>= 4.2.1'

# Auth strategies
gem "net-ldap"
gem "ladle"

# Detect encoding
gem "charlock_holmes"

# CORS support
gem "rack-cors"

# Redirections
gem 'rack-rewrite'

# Log
gem "lograge"

# Gobierto Data query analyzer
gem "pg_query"

# Gems required by Ruby 3
gem 'rexml'
gem 'net-smtp', require: false
gem 'net-pop', require: false
gem 'psych', '~> 3.3', '>= 3.3.0'
gem 'matrix'
gem "webrick", "~> 1.8"
gem 'prime'
gem 'net-imap'

group :development, :test do
  gem "i18n-tasks"
  gem "spring"
  gem "puma"
  # https://world.hey.com/lewis/run-multiple-rails-apps-with-puma-dev-67b1c10f
  gem "debug", require: false
end

group :test do
  gem "capybara"
  gem "capybara-email"
  gem "simplecov"
  gem "simplecov-cobertura"
  gem "launchy"
  gem "minitest"
  gem "minitest-reporters"
  gem "minitest-retry"
  gem "minitest-stub_any_instance"
  gem "minitest-stub-const"
  gem "minitest-ci"
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
