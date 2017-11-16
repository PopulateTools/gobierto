# frozen_string_literal: true

source "https://rubygems.org"

gem "actionpack-action_caching", git: "https://github.com/rails/actionpack-action_caching.git", ref: "9044141824650138bf27741e8f0ed95ccd9ef26d"
gem "active_model_serializers"
gem "bcrypt", "~> 3.1.0"
gem "cookies_eu"
gem "dalli"
gem "data_migrate"
gem "ine-places", "0.2.0"
gem "jbuilder", "~> 2.5"
gem "mechanize"
gem "meta-tags"
gem "paper_trail"
gem "pg", "~> 0.19"
gem "rails", "~> 5.1.1"
gem "redcarpet", require: true
gem "responders"
gem "rollbar"
gem "ruby_px"

# Frontend
gem "bourbon"
gem "cocoon"
gem "d3-rails", "~> 4.8"
gem "flight-for-rails"
gem "i18n-js", ">= 3.0.0.rc11"
gem "jquery-rails"
gem "sass-rails", "~> 5.0.0"
gem "therubyracer"
gem "turbolinks"
gem "uglifier", ">= 1.3.0"

# Elasticsearch
gem "elasticsearch"
gem "elasticsearch-extensions"

# Background processing
gem "sidekiq", "~> 5.0.4"

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
gem "redis", "~> 3.3"

# Translations
gem "i18n-active_record", require: "i18n/active_record"
gem "json_translate", "~> 3.0"

# Liquid
gem "liquid", "~> 4.0"

# Google API
gem "google-api-client"

# Microsoft Exchange calendars
gem "exchanger"

group :development, :test do
  gem "byebug", platform: :mri
  gem "i18n-tasks"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  gem "capybara"
  gem "capybara-email"
  gem "codecov", "~> 0.1.9", require: false
  gem "database_cleaner"
  gem "launchy"
  gem "minitest-rails"
  gem "minitest-rails-capybara"
  gem "minitest-reporters"
  gem "minitest-retry"
  gem "minitest-stub_any_instance"
  gem "mocha"
  gem "poltergeist"
  gem "spy"
  gem "timecop"
  gem "vcr"
  gem "webmock"
  gem "minitest-test_profile"
end

group :development do
  gem "puma"
  gem "rubocop"
end
