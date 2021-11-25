# frozen_string_literal: true

module GobiertoCommon
  class CacheService
    attr_reader :gobierto_module, :site

    def initialize(site, mod)
      @gobierto_module = mod.is_a?(String) ? mod.constantize : mod
      @site = site
    end

    def clear
      Rails.cache.delete_matched("#{cache_prefix}/*")
    end

    def delete(name, options = nil)
      Rails.cache.delete(prefixed(name), options)
    end

    def cache_prefix
      @cache_prefix ||= "#{gobierto_module.cache_base_key}#{site.id}"
    end

    def fetch(name, options = nil, &block)
      Rails.cache.fetch(prefixed(name), options, &block)
    end

    def prefixed(name)
      "#{cache_prefix}/#{name}"
    end

    # These methods are very inefficient
    def keys
      @keys ||= Rails.cache.redis.keys.select do |key|
        /\A#{cache_prefix}\//.match? key
      end
    end
  end
end
