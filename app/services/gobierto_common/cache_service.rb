# frozen_string_literal: true

module GobiertoCommon
  class CacheService
    attr_reader :gobierto_module, :site

    def initialize(site, mod)
      @gobierto_module = mod.is_a?(String) ? mod.constantize : mod
      @site = site
    end

    def clear
      Rails.cache.delete_matched(clear_match_prefix)
      Rails.cache.delete_matched(clear_match_middle)
    end

    def delete(name, options = nil)
      Rails.cache.delete(prefixed(name), options)
    end

    def delete_including(name)
      Rails.cache.delete_matched(clear_match_middle(prefixed(name)))
    end

    def cache_prefix
      @cache_prefix ||= "#{gobierto_module.cache_base_key}#{site.id}"
    end

    def fetch(name, options = nil, &block)
      Rails.cache.fetch(prefixed(name), options, &block)
    end

    def prefixed(name)
      "#{cache_prefix}/#{name.is_a?(Enumerable) ? name.join("/") : name}"
    end

    # These methods are very inefficient
    def keys
      @keys ||= if redis_cache?
                  Rails.cache.redis.keys(clear_match_prefix) + Rails.cache.redis.keys(clear_match_middle)
                else
                  Rails.cache.instance_variable_get(:@data).keys.select do |key|
                    [clear_match_prefix, clear_match_middle].any? { |expression| expression.match?(key) }
                  end
                end
    end

    def redis_cache?
      @redis_cache ||= Rails.cache.is_a? ActiveSupport::Cache::RedisCacheStore
    end

    private

    def clear_match_prefix(name = cache_prefix)
      redis_cache? ? "#{name}/*" : /\A#{name}\/.*/
    end

    def clear_match_middle(name = cache_prefix)
      redis_cache? ? "*/#{name}/*" : /.*\/#{name}\/.*/
    end
  end
end
