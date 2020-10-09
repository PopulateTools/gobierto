# frozen_string_literal: true

namespace :common do
  desc "Clear cache"
  task clear_cache: :environment do
    Rails.cache.clear
  end
end
