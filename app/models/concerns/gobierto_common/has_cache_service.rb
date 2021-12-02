# frozen_string_literal: true

module GobiertoCommon
  module HasCacheService
    extend ActiveSupport::Concern

    def cache_service
      @cache_service ||= CacheService.new(site, self.class.module_parent)
    end

    def cache_key
      [cache_service.cache_prefix, super].join("/")
    end
  end
end
