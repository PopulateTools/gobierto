# frozen_string_literal: true

module GobiertoCommon
  module CacheServiceHelper
    def cache_service_fragment(name = {}, options = {}, &block)
      key = cache_service.prefixed(name.is_a?(Enumerable) ? name.join("/") : name)

      cache(key, options, &block)
    end
  end
end
