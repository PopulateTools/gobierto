# frozen_string_literal: true

module GobiertoData
  class Cache
    def self.etag(str, current_site)
      current_site.datasets.cache_key + Digest::MD5.hexdigest(str)
    end

    def self.last_modified(current_site)
      current_site.datasets.select("MAX(updated_at) as timestamp").to_a.first.timestamp
    end
  end
end

